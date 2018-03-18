
defmodule Game.SquadSimulation do

  @buffer 50

  @doc ~S"""
  Game SquadSimulation:
  states :: Keyword [{timestamp: state} ]
  last :: Game.Squad
  """
  defstruct states: nil,
            last: nil


  # Public API

  def new(squad) do
    %__MODULE__{states: [squad], last: squad}
  end

  def state_on(%Game.Squad{:moving => false} = squad, timestamp) do
    %Game.Squad{squad | timestamp: timestamp}
  end

  def state_on(%Game.Squad{:moving => true} = squad, timestamp) do
    distance = Helpers.Time.delta(:seconds, squad.timestamp, timestamp) * squad.speed.x
    {path, position} = Game.Path.move_for(squad.path, squad.position, distance)
    %Game.Squad{squad | timestamp: timestamp, path: path, position: position}
  end

  def state_on(%__MODULE__{} = sqd_simulation, timestamp) do
    state_on(previous_state(sqd_simulation, timestamp), timestamp)
  end


  # Private functions

  defp previous_state(sqd_simulation, timestamp) do
    Enum.find(sqd_simulation.states, fn x -> x.timestamp <= timestamp end)
  end





  # def event(sqd_simulation, {:new_path, squad}) do
  #   predicted_state = state_on(sqd_simulation, squad.timestamp)
  #   update(sqd_simulation, %Game.Squad{squad | 
  #     path: squad.path,
  #     version: squad.version,
  #     timestamp: squad.timestamp,
  #     moving: true
  #   })
  # end

  # def event(sqd_simulation, {:new_formation, squad}) do
  #   predicted_state = state_on(sqd_simulation, squad.timestamp)
  #   update(sqd_simulation, %Game.Squad{squad | 
  #     formation: squad.formation,
  #     speed: squad.speed,
  #     version: squad.version,
  #     timestamp: squad.timestamp
  #   })  
  # end

  # def event(sqd_simulation, {:skill_used, squad}) do
        
  # end





  



#   def state_on(%__MODULE__{} = simulation, time) do
#     # state_on(simulation.last, time)
#   end

#   def state_on(%Game.Squad{:path => nil} = squad, time) do
#     %Game.Squad{squad | timestamp: time}
#   end

#   def state_on(%Game.Squad{} = squad, time) do
#     distance = Helpers.Time.delta(:seconds, squad.timestamp, time) * squad.speed.x
#     {path, position} = Game.Path.move_for(squad.path, squad.position, distance)
#     %Game.Squad{squad | timestamp: time, path: path, position: position}
#   end

#   # def predicted_state_of(simulation, squad) do
#   #   previous = Enum.find(simulation.states, fn x -> x.checksum <= squad.checksum end)
#   #   state_on(previous, squad.timestamp)
#   # end

#   def update(
#     %__MODULE__{last: %Game.Squad{checksum: sim_stamp}} = sim,
#     %Game.Squad{checksum: new_stamp} = state
#   ) when sim_stamp <= new_stamp do
#     %__MODULE__{sim | states: [state | sim.states] |> Enum.take(-@buffer), last: state}
#   end 

#   def update(simulation, state) do
#     position = Enum.find_index(simulation.states, fn s -> state.checksum > s.checksum end)
#     index = if (position), do: position, else: length(simulation.states)
#     unadjusted_states = List.insert_at(simulation.states, index, state)
#     [_ | previous_states] = unadjusted_states ++ [nil]
 
#     states = Stream.with_index(unadjusted_states)
#               |> Stream.zip(previous_states)
#               |> Enum.map(fn {{curr, idx}, prev} ->
#                   cond do
#                     idx >= index -> curr
#                     idx < index -> adjust_state(curr, prev)
#                   end
#                 end)

#     %__MODULE__{simulation | states: states |> Enum.take(-@buffer), last: Enum.at(states, 0)}
#   end

#   defp adjust_state(last, previous) do
#     calculated_state = state_on(previous, last.timestamp)
#     %Game.Squad{last | path: calculated_state.path, position: calculated_state.position}
#   end
  
end