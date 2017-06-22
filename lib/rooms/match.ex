
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
            simulation: nil,
            connection: nil


  def start_link(user_0, user_1) do
    GenServer.start_link(__MODULE__, {user_0, user_1}, [])
  end



  # Genserver Callbacks
  def init({user_0, user_1}) do
    simulation = 0
    connection = 0
    squads = [
        %Game.Squad{side: 0, name: Enum.at(user_0.squads, 0)},
        %Game.Squad{side: 1, name: Enum.at(user_1.squads, 0)}
    ]
    state = %__MODULE__{
        user_0: user_0, 
        user_1: user_1, 
        squads: squads, 
        simulation: simulation, 
        connection: connection
    }
    {:ok, state}
  end

  def handle_cast({:new_path, squad_name}, state) do
    IO.puts(squad_name)
    {:noreply, state}
  end

end