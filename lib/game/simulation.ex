
defmodule Game.Simulation do
  use GenServer

  @doc ~S"""
  Game.Simulation:
  stash :: PID
  match :: PID
  squads :: MAP %{SquadName => Game.SquadSimulation}
  """
  defstruct stash: nil,
            match: nil,
            squads: %{},
            offset: 0

  def start_link(match, user_0, user_1, stash) do
    saved_state = stash |> Helpers.Stash.get(:simulation)
    params = {match, user_0, user_1, stash, saved_state}
    GenServer.start_link(__MODULE__, params, [])
  end

  def init({match, user_0, user_1, stash, nil}) do
    squads = user_0.squads ++ user_1.squads
    state = %__MODULE__{
        stash: stash,
        match: match,
        squads: Enum.map(squads, fn s -> Game.SquadSimulation.start(s) end)
    }
    {:ok, state}
  end

  def init({match, user_0, user_1, stash, saved_state}) do
    state = %__MODULE__{
        stash: stash,
        match: match,
        squads: saved_state.squads
    }
    {:ok, state}
  end

  def terminate(_reason, state) do
    state.stash |> Helpers.Stash.set(:simulation, state)
  end

  def process(data) do
    #Something happens
  end

  def set_time_offset(pid, offset) do
    GenServer.call(pid, {:set_offset, offset})
  end


  #private
  defp handle_call({:set_offset, offset}, _from, state) do
    {:reply, nil, %__MODULE__{state | offset: offset}}
  end 
end