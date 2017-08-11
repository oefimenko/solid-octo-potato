
defmodule Game.Simulation do
  use GenServer

  @doc ~S"""
  Game.Simulation:
  stash :: PID
  match :: PID
  squads :: MAP %{SquadName => Game.SquadHistory}
  """
  defstruct stash: nil,
            match: nil,
            squads: %{}

  def start_link(match, user_0, user_1, stash) do
    saved_state = stash |> Helpers.Stash.get(:connection)
    params = {match, user_0, user_1, stash, saved_state}
    GenServer.start_link(__MODULE__, params, [])
  end

  def init({match, user_0, user_1, stash, nil}) do
    squads = %{}
    state = %__MODULE__{
        stash: stash,
        match: match,
        squads: squads
    }
    {:ok, state}
  end

  def init({match, user_0, user_1, stash, saved_state}) do
    
  end

end