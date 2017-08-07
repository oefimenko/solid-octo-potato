
defmodule Conn.UDP do
  use GenServer
  
  @ack_timeout 1000

  def start_link(deserializer, port, stash, hash_1, hash_2) do
    saved_state = stash |> Helpers.Stash.get(:connection)
    params = {deserializer, port, stash, hash_1, hash_2, saved_state}
    GenServer.start_link(__MODULE__, params, [])
  end

  # Init if no previous state was exist
  def init({deserializer, port, stash, hash_1, hash_2, nil}) do
    {:ok, socket} = :gen_udp.open(port, [:binary])

    state = %{
      ips: %{hash_1 => nil, hash_2 => nil},
      deserializer: deserializer,
      stash: stash,
      socket: socket,
      ack_list: %{}
    }
    {:ok, state}
  end

  # Init if previous state was exist
  def init({deserializer, port, stash, _hash_1, _hash_2, saved_state}) do
    {:ok, socket} = :gen_udp.open(port, [:binary])
    state = %{saved_state | stash: stash, deserializer: deserializer, socket: socket}
    {:ok, state}
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

  # ACK received
  def handle_info({:udp, _sck, _ip, _port, <<
                                              1, 
                                              _a, 
                                              stamp :: bitstring-size(128), 
                                              _ :: binary
                                            >>}, state) do
    {:noreply, %{state | ack_list: Map.delete(state.ack_list, stamp)}}
  end

  # Request with ack needed received
  def handle_info({:udp, _sck, ip, port, <<
                                            0,
                                            1,
                                            stamp :: bitstring-size(128),
                                            hash :: bitstring-size(128),
                                            data :: binary
                                          >>}, state) do
    msg = <<1, 0>> <> stamp
    :gen_udp.send(state.socket, ip, port, msg)
    state.deserializer |> send(data)
    {:noreply, %{state | ips: %{state.ips | hash => {ip, port}} }}
  end

  # Request with no ack needed received
  def handle_info({:udp, _sck, ip, port, <<
                                            0,
                                            0,
                                            _stamp :: bitstring-size(128),
                                            hash :: bitstring-size(128),
                                            data :: binary
                                          >>}, state) do
    state.deserializer |> send(data)
    {:noreply, %{state | ips: %{state.ips | hash => {ip, port}} }}
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
  def handle_cast({:async_no_ack, data}, state) do
    Enum.each(state.ips, fn({_hash, {ip, port}}) -> 
      {_id, msg} = with_headers({0, 1}, data)
      :gen_udp.send(state.socket, ip, port, msg)
    end)
    {:noreply, state}
  end

  # Async send with ack
  def handle_cast({:async_ack, data}, state) do
    ack_list = Enum.map(state.ips, fn({hash, {ip, port}}) ->
      {id, msg} = with_headers({0, 1}, data)
      :gen_udp.send(state.socket, ip, port, msg)
      self() |> Process.send_after({:redeliver, id}, @ack_timeout)
      {id, {hash, msg}}
    end)
    new_state = %{state | ack_list: Map.new(ack_list)}
    {:noreply, new_state}
  end

  # Sync send with ack
  def handle_call({:sync_ack, data}, _from, state) do
    Enum.map(state.ips, fn({_hash, {ip, port}}) ->
      emit_sync(state.socket, ip, port, data)
    end)
    {:reply, nil, state}
  end

  def emit_sync(socket, ip, port, data) do
    {id, msg} = with_headers({0, 1}, data)
    pub = fn
      ({:ok, data}) -> data
      (fun) -> fun.(receive do
        ({:udp, _port, ^ip, data}) -> {:ok, data}
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
  defp with_headers({type, need_ack}, data) do
    {date, hour, sec} = :erlang.timestamp
    time = Integer.to_string(date) <> Integer.to_string(hour) <> Integer.to_string(sec) 
           |> String.pad_trailing(16, "0")
    {time, <<type, need_ack>> <> time <> data}
  end
end
