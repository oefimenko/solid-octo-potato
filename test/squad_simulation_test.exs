defmodule SquadSimulationTest do
  alias Game.Path, as: Path
  alias Game.Simulation, as: Simulation
  alias Game.Squad, as: Squad
  alias Game.SquadSimulation, as: SquadSimulation
  alias Game.Vector, as: Vector

  use ExUnit.Case
  doctest SquadSimulation
  
  setup_all do
    squad = %Squad{Squad.init(:skeletons, "testSquad") |
      health: 100,
      damage: 1,
      position: %Vector{x: 0.0, y: 0.0},
      timestamp: 0,
      speed: %Vector{x: 2.0, y: 2.0}
    }
    squad_simulation = SquadSimulation.new(squad)
    path = %Path{
      points: [%Vector{x: 1, y: 1}, %Vector{x: 3, y: 3}, %Vector{x: 5, y: 5}],
      total: 3
    }
    {:ok, squad: squad, squad_simulation: squad_simulation, path: path}
  end

  test "Can calculate predicted state for not moving squad", state do
    expected_sqd_state = %Squad{state.squad | timestamp: 1}
    assert SquadSimulation.state_on(state.squad, 1) == expected_sqd_state
  end

#   for [
#     %Path{points: [%Vector{x: 1, y: 1}, %Vector{x: 3, y: 3}, %Vector{x: 5, y: 5}], total: 3 }
#   ]


  for {stamp, x, y, nxt_point} = param <- [
      {250000, 0.3535, 0.3535, 0},
      {750000, 1.0606, 1.0606, 1},
      {3000000, 4.24264, 4.24264, 2},
      {4000000, 5, 5, nil}
    ] do
    @stamp stamp
    @x x
    @y y
    @nxt_point nxt_point
    test "Can calculate predicted state for moving squad less the point (#{Kernel.inspect(param)})", state do
        squad = %Squad{state.squad | moving: true, path: state.path}
        expected_sqd_state = %Squad{squad | 
          timestamp: @stamp,
          position: nil,
          path: %Path{squad.path | next_point: @nxt_point}
        }
        expected_position = %Vector{x: @x, y: @y}
        calculated_state = SquadSimulation.state_on(squad, @stamp)
        calculated_position = calculated_state.position
        assert %Squad{calculated_state | position: nil} == expected_sqd_state
        assert_in_delta expected_position.x, calculated_position.x, 0.005
        assert_in_delta expected_position.y, calculated_position.y, 0.005
      end
  end



#   test "Can calculate predicted state for moving squad from continuing path", state do
#     squad = Squad{state.squad | moving: true}
#     expected_sqd_state = Squad{squad | timestamp: 1}
#     assert SquadSimulation.state_on(squad, 1) == expected_sqd_state
#   end



  


#   test "Can calculate predicted state for squad moving for some time", state do
#     assert 1 + 1 == 1
#   end

#   test "Can calculate predicted state for squad_simulation", state do
#     # 3 asserts in one
#     assert 1 + 1 == 1
#   end

#   test "Can calculate predicted state and store it", state do
#     # 3 asserts in one
#     assert 1 + 1 == 1
#   end

#   test "Can apply new event", state do
#     # 3 asserts in one
#     assert 1 + 1 == 1
#   end

#   test "Can apply missed event", state do
#     # 3 asserts in one
#     assert 1 + 1 == 1
#   end
  
#   test "Can apply new path event", state do
#     # 3 asserts in one
#     assert 1 + 1 == 1
#   end

#   test "Can apply formation event", state do
#     # 3 asserts in one
#     assert 1 + 1 == 1
#   end

end
