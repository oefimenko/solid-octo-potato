
defmodule Conn.UDP do
  use GenServer
  
  @ack_timeout 1000

  def start_link(deserializer, port, stash, hash_1, hash_2) do
    saved_state = stash |> Helpers.Stash.get(:connection)
    params = {deserializer, port, stash, hash_1, hash_2, saved_state}
    GenServer.start_link(__MODULE__, params, [])
  end

  def init_state(deserializer, port, stash, ips) do
    {:ok, socket} = :gen_udp.open(port, [:binary])
    %{
      ips: ips,
      deserializer: deserializer,
      stash: stash,
      socket: socket,
      ack_list: %{}
    }
  end

  # Init if no previous state was exist for 1 player
  def init({deserializer, port, stash, hash_1, nil, nil}) do
    {:ok, init_state(deserializer, port, stash, %{hash_1 => nil})}
  end

  # Init if no previous state was exist for 2 players
  def init({deserializer, port, stash, hash_1, hash_2, nil}) do
    {:ok, init_state(deserializer, port, stash, %{hash_1 => nil, hash_2 => nil})}
  end

  # Init if previous state was exist
  def init({deserializer, port, stash, _hash_1, _hash_2, saved_state}) do
    {:ok, socket} = :gen_udp.open(port, [:binary])
    state = %{saved_state | stash: stash, deserializer: deserializer, socket: socket}
    {:ok, state}
  end
  
  def terminate(_reason, state) do
    state.stash |> Helpers.Stash.set(:connection, state)
  end

  def send(pid, {:sync, :ack}, data) do
    GenServer.call(pid, {:sync, :ack, data}, 15000)
  end

  def send(pid, {:async, :ack}, data) do
    GenServer.cast(pid, {:async, :ack, data})
  end

  def send(pid, {:async, :no_ack}, data) do
    GenServer.cast(pid, {:async, :nack, data})
  end

  def send(pid, {:latency}, data) do
    GenServer.call(pid, {:latency, data}, 60000)
  end

  def send(pid, {:sync_time}, offsets) do
    GenServer.call(pid, {:sync_time, offsets}, 15000)
  end

  #  ACK received
  def handle_info({:udp, _sck, _ip, _port, <<
                                              1, 
                                              _a, 
                                              stamp :: binary-size(16), 
                                              _ :: binary
                                            >>}, state) do
    {:noreply, %{state | ack_list: Map.delete(state.ack_list, stamp)}}
  end

  # Request with ack needed received
  def handle_info({:udp, _sck, ip, port, <<
                                            0,
                                            1,
                                            stamp :: binary-size(16),
                                            hash :: bitstring-size(128),
                                            data :: binary
                                          >>}, state) do
    msg = <<1, 0>> <> stamp
    :gen_udp.send(state.socket, ip, port, msg)
    state.deserializer |> send({data, hash})
    ips = Map.put(state.ips, hash, {ip, port})
    {:noreply, %{state | ips: ips}}
  end

  # Request with no ack needed received
  def handle_info({:udp, _sck, ip, port, <<
                                            0,
                                            0,
                                            _stamp :: binary-size(16),
                                            hash :: bitstring-size(128),
                                            data :: binary
                                          >>}, state) do
    state.deserializer |> send({data, hash})
    ips = Map.put(state.ips, hash, {ip, port})
    {:noreply, %{state | ips: ips}}
  end

  # Task for message redeliver
  def handle_info({:redeliver, id}, state) do
    if Map.has_key?(state.ack_list, id) do
      {:ok, {hash, msg}} = Map.fetch(state.ack_list, id)
      {ip, port} = Map.fetch(state.ip, hash)
      :gen_udp.send(state.socket, ip, port, msg)
      Process.send_after(self(), {:redeliver, id}, @ack_timeout)
    end
    {:noreply, state}
  end

  # Ignore everything else
  def handle_info(_, state) do
    {:noreply, state}
  end
  
  # Async send without ack
  def handle_cast({:async, no_ack, data}, state) do
    Enum.each(state.ips, fn({hash, {ip, port}}) -> 
      {_id, msg} = with_headers({0, 1}, hash, data)
      :gen_udp.send(state.socket, ip, port, msg)
    end)
    {:noreply, state}
  end

  # Async send with ack
  def handle_cast({:async, :ack, data}, state) do
    ack_list = Enum.each(state.ips, fn({hash, {ip, port}}) ->
      {id, msg} = with_headers({0, 1}, hash, data)
      :gen_udp.send(state.socket, ip, port, msg)
      self() |> Process.send_after({:redeliver, id}, @ack_timeout)
      {id, {hash, msg}}
    end)
    new_state = %{state | ack_list: Map.new(ack_list)}
    {:noreply, new_state}
  end

  # Sync send with ack
  def handle_call({:sync, :ack, data}, _from, state) do
    Enum.each(state.ips, fn({hash, {ip, port}}) ->
      emit_sync(state.socket, ip, port, hash, data)
    end)
    {:reply, {:ok}, state}
  end

  def handle_call({:latency, data}, _from, state) do
    result = Enum.map(state.ips, fn({hash, {ip, port}}) ->
      avg_latency = Enum.map(0..9, fn _ ->
        time = Helpers.Time.current(:int)
        emit_sync(state.socket, ip, port, hash, data)
        Helpers.Time.delta(:micro_seconds, time, Helpers.Time.current(:int))
      end)
      |> Enum.sum
      |> Kernel./(20)
      |> Float.ceil(0)
      |> round
      {hash, avg_latency}
    end)
    |> Map.new
    state.deserializer |> send({{:latency, result}})
    {:reply, {:ok}, state}
  end

  def handle_call({:sync_time, {msg_id, offsets}}, _from, state) do
    Enum.each(offsets, fn({hash, offset}) ->
      {ip, port} = state.ips |> Map.fetch!(hash)
      emit_sync(state.socket, ip, port, hash, msg_id <> Integer.to_string(offset))
    end)
    state.deserializer |> send({{:sync_time, :ok}})
    {:reply, {:ok}, state}
  end

  def emit_sync(socket, ip, port, hash, data) do
    {id, msg} = with_headers({0, 1}, hash, data)
    pub = fn
      ({:ok, data}) -> data
      (fun) -> fun.(receive do
        ({:udp, _s, _ip, _p, <<1, 0, ^id::binary>> = data}) -> {:ok, data}
        ({:reemit, ^id}) -> :gen_udp.send(socket, ip, port, msg);
                            Process.send_after(self(), {:reemit, id}, 2000);
                            fun
        (_) -> fun
      end)
    end
    Process.send_after(self(), {:reemit, id}, 2000)
    :gen_udp.send(socket, ip, port, msg)
    pub.(pub)
  end

  # type     :: 0 msg || 1 ack
  # need_ack :: 0 no || 1 yes
  # time     :: 16
  # structure ->
  # << type, need_ack, time, sep(0), data >>
  defp with_headers({type, need_ack}, hash, data) do
    time = Helpers.Time.current(:string)
    {time, <<type, need_ack>> <> time <> hash <> data}
  end
end
