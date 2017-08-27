
defmodule Game.SquadSimulation do

  @doc ~S"""
  Game SquadSimulation:
  states :: Keyword [{timestamp: state} ]
  current :: Game.Squad
  """
  defstruct states: nil,
            current: nil

  def start(squad) do
    %__MODULE__{states: [{squad.version, squad}], current: squad}
  end

  def current(simulation) do
    Enum.at(simulation.state, -1)
  end

  def state_on(%__MODULE__{} = simulation, time) do
    state_on(simulation.current, time)
  end

  def state_on(%Game.Squad{:path => nil} = squad, time) do
    %Game.Squad{squad | timestamp: time}
  end

  def state_on(%Game.Squad{} = squad, time) do
    distance = Helpers.Time.delta(:seconds, squad.timestamp, time) * squad.speed.x
    {path, position} = Game.Path.move_for(squad.path, squad.position, distance)
    %Game.Squad{squad | timestamp: time, path: path, position: position}
  end

  def update(
    %__MODULE__{:current => %Game.Squad{:timestamp => sim_stamp}} = sim,
    %Game.Squad{:timestamp => new_tamp} = state
  ) when sim_stamp <= new_tamp do
    %__MODULE__{sim.states ++ [state] |> Enum.take(-50) | current: state}
  end

  def update(simulation, state) do
    index = Enum.find_index(simulation, fn s -> state.timestamp > s.timestamp end)
    raw_states = List.insert_at(simulation.states, index, state)
    states = (0..Enum.count(raw_states) - 1) 
             |> Enum.map(fn x ->
               case x do
                 x when x <= index -> Enum.at(raw_states, x)
                 x -> adjust_state(Enum.at(raw_states, x), Enum.at(raw_states, x - 1))
               end
             end)

    %__MODULE__{simulation | states: states, current: Enum.at(states, -1)}
  end

  defp adjust_state(current, previous) do
    calculated_state = state_on(previous, current.timestamp)
    %Game.Squad{current | path: previous.path, position: previous.position}
  end
  
end