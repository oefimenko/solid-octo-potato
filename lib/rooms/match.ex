
defmodule Rooms.Match do
  use GenServer

  @doc ~S"""
  Rooms.Match:
  user_0 :: App.User
  user_1 :: App.User
  squads :: [Game.Squad]
  simulation :: pid
  connection :: pid
  """
  defstruct user_0: nil,
            user_1: nil,
            squads: nil,
            serializer: nil,
            deserializer: nil,
            conn: nil

  def start_link(user_0, user_1) do
    GenServer.start_link(__MODULE__, {user_0, user_1}, [])
  end

  def receive(pid, data) do
    GenServer.cast(pid, data)
  end

  # Genserver Callbacks
  def init({user_0, user_1}) do
    port = 21001
    {:ok, serializer} = spawn_link(Conn.Serializer, :run, [])
    {:ok, deserializer} = spawn_link(Conn.Deserializer, :run, [])
    {:ok, conn} = Conn.UDP.start_link(self(), user_0.ip, user_1.ip, port)
    squads = [
        %Game.Squad{side: 0, name: Enum.at(user_0.squads, 0)},
        %Game.Squad{side: 1, name: Enum.at(user_1.squads, 0)}
    ]
    state = %__MODULE__{
        user_0: user_0, 
        user_1: user_1, 
        squads: squads, 
        serializer: serializer,
        deserializer: deserializer,
        conn: conn
    }
    init_msg = {port, user_0, 0, user_1, 1, squads}
    Conn.UDP.send(:sync, :ack, state.conn, serializer |> serialize({0, init_msg}))
    {:ok, state}
  end

  def handle_cast(data, state) do
    result = process_request(deserialize(state.deserializer, data))
    msg = state.serializer |> serialize(result)
    Conn.UDP.send(:async, :ack, state.conn, msg)
    {:noreply, state}
  end

  # private
  defp serialize(serializer, {type, obj}) do
    send(serializer, {self(), type, obj})
    data = receive do
      {data} -> data
    end
    data
  end

  # private
  defp deserialize(deserializer, obj) do
    send(deserializer, {self(), obj})
    msg = receive do
      {type, data} -> {type, data}
    end
    msg
  end

  defp process_request({1, squad}) do
    {1, squad}
  end

  defp process_request({2, squad}) do
    {2, squad}
  end

  defp process_request({3, squad}) do
    {3, squad}
  end

  defp process_request({4, squad}) do
    {4, squad}
  end
end
