
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
            conn: nil,
            ready: MapSet.new

  def start_link(user_0, user_1, l_port) do
    GenServer.start_link(__MODULE__, {user_0, user_1, l_port}, [])
  end

  def receive(pid, data) do
    GenServer.cast(pid, data)
  end

  # Genserver Callbacks
  def init({user_0, user_1, port}) do
    serializer = spawn_link(Conn.Serializer, :run, [])
    deserializer = spawn_link(Conn.Deserializer, :run, [])
    {:ok, conn} = Conn.UDP.start_link(self(), port)
    squads = [
        %Game.Squad{side: 0, type: Enum.at(user_0.squads, 0), name: user_0.name <> Enum.at(user_0.squads, 0), position: %Game.Vector{x: 2000, y: 2000}},
        %Game.Squad{side: 1, type: Enum.at(user_1.squads, 0), name: user_1.name <> Enum.at(user_1.squads, 0), position: %Game.Vector{x: -2000, y: -2000}}
    ]
    state = %__MODULE__{
        user_0: user_0,
        user_1: user_1,
        squads: squads,
        serializer: serializer,
        deserializer: deserializer,
        conn: conn
    }
    {:ok, state}
  end

  def handle_cast(data, state) do
    state = state.deserializer |> deserialize(data) |> process_request(state)
    {:noreply, state}
  end

  # private
  defp serialize(serializer, {type, obj}) do
    send(serializer, {self(), type, obj})
    data = receive do
      (data) -> data
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

  defp process_request({:squad_state, squad}, state) do
    msg = state.serializer |> serialize({:squad_state, squad})
    Conn.UDP.send(state.conn, :async, :no_ack, msg)
    state
  end

  defp process_request({:new_path, squad}, state) do
    msg = state.serializer |> serialize({:new_path, squad})
    Conn.UDP.send(state.conn, :async, :ack, msg)
    state
  end

  defp process_request({:new_formation, squad}, state) do
    msg = state.serializer |> serialize({:new_formation, squad})
    Conn.UDP.send(state.conn, :async, :ack, msg)
    state
  end

  defp process_request({:skill_used, squad}, state) do
    msg = state.serializer |> serialize({:skill_used, squad})
    Conn.UDP.send(state.conn, :async, :ack, msg)
    state
  end

  defp process_request({:conn, user_name}, state) do
    new_state = %__MODULE__{state | ready: MapSet.put(state.ready, user_name)}
    if MapSet.size(new_state.ready) >= 2 do
      body = {state.user_0.name, state.user_1.name, state.squads}
      init_msg = state.serializer |> serialize({:init, body})
      Conn.UDP.send(state.conn, :sync, :ack, init_msg)
    end
    new_state
  end

  defp process_request({_, _squad}, state) do
    state
  end

end
