
defmodule Conn.UDP do
  use GenServer
  
  @ack_timeout 1500

  def start_link(match, port) do
    GenServer.start_link(__MODULE__, {match, port}, [])
  end

  def init({match, port}) do
    {:ok, socket} = :gen_udp.open(port, [:binary])
    state = %{
      ips: MapSet.new,
      match: match,
      socket: socket,
      ack_list: %{}
    }
    {:ok, state} 
  end

  def send(pid, :sync, :ack, data) do
    IO.inspect({:sync, data})
    GenServer.call(pid, {:sync_ack, data}, 15000)
  end

  def send(pid, :async, :ack, data) do
    IO.inspect({:async, :ack, data})
    GenServer.cast(pid, {:async_ack, data})
  end

  def send(pid, :async, :no_ack, data) do
    IO.inspect({:async, :no_ack, data})
    GenServer.cast(pid, {:async_no_ack, data})
  end

  # ACK received
  def handle_info({:udp, _sck, _ip, _port, <<1, _a, stamp :: bitstring-size(128), _ :: binary>>}, state) do
    {:noreply, %{state | ack_list: Map.delete(state.ack_list, stamp)}}
  end

  # Request with ack needed received
  def handle_info({:udp, _sck, ip, port, <<0, 1, stamp :: bitstring-size(128), data :: binary>>}, state) do
    msg = <<1, 0>> <> stamp
    :gen_udp.send(state.socket, ip, port, msg)
    Rooms.Match.receive(state.match, data)
    {:noreply, %{state | ips: MapSet.put(state.ips, {ip, port})}}
  end

  # Request with no ack needed received
  def handle_info({:udp, _sck, ip, port, <<0, 0, _stamp :: bitstring-size(128), data :: binary>>}, state) do
    Rooms.Match.receive(state.match, data)
    {:noreply, %{state | ips: MapSet.put(state.ips, {ip, port})}}
  end

  # Task for message redeliver
  def handle_info({:sync, id}, state) do
    if Map.has_key?(state.ack_list, id) do
      {:ok, {ip, port, msg}} = Map.fetch(state.ack_list, id)
      :gen_udp.send(state.socket, ip, port, msg)
      Process.send_after(self(), {:sync, id}, @ack_timeout)
    end
    {:noreply, state}
  end

  # Ignore everything else
  def handle_info(_s, state) do
    {:noreply, state}
  end
  
  # Async send without ack
  def handle_cast({:async_no_ack, data}, state) do
    Enum.each(state.ips, fn({ip, port}) -> 
      {_id, msg} = with_headers({0, 1}, data)
      :gen_udp.send(state.socket, ip, port, msg)
    end)
    {:noreply, state}
  end

  # Async send with ack
  def handle_cast({:async_ack, data}, state) do
    ack_list = Enum.map(state.ips, fn({ip, port}) ->
      {id, msg} = with_headers({0, 1}, data)
      :gen_udp.send(state.socket, ip, port, msg)
      Process.send_after(self(), {:sync, id}, @ack_timeout)
      {id, {ip, port, msg}}
    end)
    new_state = %{state | ack_list: Map.new(ack_list)}
    {:noreply, new_state}
  end

  # Sync send with ack
  def handle_call({:sync_ack, data}, _from, state) do
    Enum.map(state.ips, fn({ip, port}) ->
      emit_sync(state.socket, ip, port, data)
    end)
    {:reply, nil, state}
  end

  def emit_sync(socket, ip, port, data) do
    {id, msg} = with_headers({0, 1}, data)
    pub = fn
      ({:ok, data}) -> data
      (fun) -> fun.(receive do
        ({:udp, _port, ^ip, port, data}) -> {:ok, data}
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
