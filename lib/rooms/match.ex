
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
            conn: nil

  def start_link(user_0, user_1) do
    GenServer.start_link(__MODULE__, {user_0, user_1}, [])
  end



  # Genserver Callbacks
  def init({user_0, user_1}) do
    squads = [
        %Game.Squad{side: 0, name: Enum.at(user_0.squads, 0)},
        %Game.Squad{side: 1, name: Enum.at(user_1.squads, 0)}
    ]
    state = %__MODULE__{
        user_0: user_0, 
        user_1: user_1, 
        squads: squads, 
        serializer: spawn(Game.Serializer, :run, []),
        conn: Conn.UDP.start_link(self(), user_0.ip, user_1.ip)
    }
    Enum.each(squads, fn(sq) -> 
      Conn.UDP.send(state.conn, serialize(sq, state.serializer)) 
    end)
    {:ok, state}
  end

  def handle_cast({:new_path, squad_name}, state) do
    {:noreply, state}
  end

  # private
  defp serialize(obj, serializer) do
    type = case obj do
      %Game.Squad{} -> :squad
    end
    send(serializer, {self(), type, obj})
    data = receive do
      {data} -> data
    end
    data
  end

end
