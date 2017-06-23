
defmodule Conn.UDP do
  use GenServer

  def start_link(match, ip0, ip1) do
    GenServer.start_link(__MODULE__, {match, {ip0, ip1}}, [])
  end

  def init({match, {ip0, ip1}}) do
    {:ok, socket} = :gen_udp.open(21000)
    {:ok, {{ip0, ip1}, match, socket}} 
  end

  def send(pid, data) do
    GenServer.cast(pid, {:send, data})
  end

  # Handle UDP data
  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    IO.puts inspect(data)
    {:noreply, state}
  end

  # Ignore everything else
  def handle_info({_, _socket}, state) do
    {:noreply, state}
  end
  
  def handle_cast({:send, data}, state) do
    Enum.each(Enum.at(state, 0), fn(ip) -> 
        :gen_udp.send(Enum.at(state, 2), ip, 21000, data) end)
    {:noreply, state}
  end

end