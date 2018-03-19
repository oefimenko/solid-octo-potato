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

  @path_1 Path.new([Vector.new(1, 1), Vector.new(3, 3), Vector.new(5, 5)])
  @path_2 Path.new([Vector.new(1, 0), Vector.new(3, 0), Vector.new(5, 0)])
  @path_3 Path.new([Vector.new(1, -1), Vector.new(3, -3), Vector.new(5, -5)])
  @path_4 Path.new([Vector.new(0, -1), Vector.new(0, -3), Vector.new(0, -5)])
  @path_5 Path.new([Vector.new(-1, -1), Vector.new(-3, -3), Vector.new(-5, -5)])
  @path_6 Path.new([Vector.new(-1, 0), Vector.new(-3, 0), Vector.new(-5, 0)])
  @path_7 Path.new([Vector.new(-1, 1), Vector.new(-3, 3), Vector.new(-5, 5)])
  @path_8 Path.new([Vector.new(0, 1), Vector.new(0, 3), Vector.new(0, 5)])

  for {test_i, path, start, finish, path_nxt, stamp} <- [
    {0, @path_1, Vector.new(0, 0), Vector.new(0.3535, 0.3535), 0, 250000},
    {1, @path_1, Vector.new(0, 0), Vector.new(1.0606, 1.0606), 1, 750000},
    {2, @path_1, Vector.new(0, 0), Vector.new(4.24264, 4.24264), 2, 3000000},
    {3, @path_1, Vector.new(0, 0), Vector.new(5, 5), nil, 4000000},

    {4, @path_1, Vector.new(0.1, 0.1), Vector.new(0.4535, 0.4535), 0, 250000},
    {5, @path_1, Vector.new(0.1, 0.1), Vector.new(1.1606, 1.1606), 1, 750000},
    {6, @path_1, Vector.new(0.1, 0.1), Vector.new(4.34264, 4.34264), 2, 3000000},
    {7, @path_1, Vector.new(0.1, 0.1), Vector.new(5, 5), nil, 4000000},

    {8, @path_2, Vector.new(0.1, 0), Vector.new(0.6, 0), 0, 250000},
    {9, @path_2, Vector.new(0.1, 0), Vector.new(1.6, 0), 1, 750000},
    {10, @path_2, Vector.new(0.1, 0), Vector.new(4.1, 0), 2, 2000000},
    {11, @path_2, Vector.new(0.1, 0), Vector.new(5, 0), nil, 4000000},

    {12, @path_3, Vector.new(0.1, -0.1), Vector.new(0.4535, -0.4535), 0, 250000},
    {13, @path_3, Vector.new(0.1, -0.1), Vector.new(1.1606, -1.1606), 1, 750000},
    {14, @path_3, Vector.new(0.1, -0.1), Vector.new(4.34264, -4.34264), 2, 3000000},
    {15, @path_3, Vector.new(0.1, -0.1), Vector.new(5, -5), nil, 4000000},

    {16, @path_4, Vector.new(0, -0.1), Vector.new(0, -0.6), 0, 250000},
    {17, @path_4, Vector.new(0, -0.1), Vector.new(0, -1.6), 1, 750000},
    {18, @path_4, Vector.new(0, -0.1), Vector.new(0, -4.1), 2, 2000000},
    {19, @path_4, Vector.new(0, -0.1), Vector.new(0, -5), nil, 4000000},

    {20, @path_5, Vector.new(-0.1, -0.1), Vector.new(-0.4535, -0.4535), 0, 250000},
    {21, @path_5, Vector.new(-0.1, -0.1), Vector.new(-1.1606, -1.1606), 1, 750000},
    {22, @path_5, Vector.new(-0.1, -0.1), Vector.new(-4.34264, -4.34264), 2, 3000000},
    {23, @path_5, Vector.new(-0.1, -0.1), Vector.new(-5, -5), nil, 4000000},

    {24, @path_6, Vector.new(-0.1, 0), Vector.new(-0.6, 0), 0, 250000},
    {25, @path_6, Vector.new(-0.1, 0), Vector.new(-1.6, 0), 1, 750000},
    {26, @path_6, Vector.new(-0.1, 0), Vector.new(-4.1, 0), 2, 2000000},
    {27, @path_6, Vector.new(-0.1, 0), Vector.new(-5, 0), nil, 4000000},

    {28, @path_7, Vector.new(-0.1, 0.1), Vector.new(-0.4535, 0.4535), 0, 250000},
    {29, @path_7, Vector.new(-0.1, 0.1), Vector.new(-1.1606, 1.1606), 1, 750000},
    {30, @path_7, Vector.new(-0.1, 0.1), Vector.new(-4.34264, 4.34264), 2, 3000000},
    {31, @path_7, Vector.new(-0.1, 0.1), Vector.new(-5, 5), nil, 4000000},

    {32, @path_8, Vector.new(0, 0.1), Vector.new(0, 0.6), 0, 250000},
    {33, @path_8, Vector.new(0, 0.1), Vector.new(0, 1.6), 1, 750000},
    {34, @path_8, Vector.new(0, 0.1), Vector.new(0, 4.1), 2, 2000000},
    {35, @path_8, Vector.new(0, 0.1), Vector.new(0, 5), nil, 4000000},
  ] do
    @test_i test_i
    @path path
    @start start
    @finish finish
    @path_nxt path_nxt
    @stamp stamp
    test "Can calculate predicted state for moving squad less the point (#{Kernel.inspect(@test_i)})", state do
        squad = %Squad{state.squad | moving: true, path: @path, position: @start}
        expected_sqd_state = %Squad{squad | 
          timestamp: @stamp,
          position: nil,
          path: %Path{squad.path | next_point: @path_nxt}
        }
        calculated_state = SquadSimulation.state_on(squad, @stamp)
        calculated_position = calculated_state.position
        assert %Squad{calculated_state | position: nil} == expected_sqd_state
        assert_in_delta @finish.x, calculated_position.x, 0.005
        assert_in_delta @finish.y, calculated_position.y, 0.005
      end
  end

  for {stamp, finish, next_point, description} <- [
    {1000000, Vector.new(4.9142, 4.9142), 2, "and not finishshing"},
    {2000000, Vector.new(5, 5), nil, "and finishshing"},
  ] do
    @stamp stamp
    @finish finish
    @next_point next_point
    test "Can calculate predicted state for moving squad from continuing path #{description}", state do
      continuing_path = %Path{state.path | next_point: 2}
      squad = %Squad{state.squad | moving: true, position: Vector.new(3.5, 3.5), path: continuing_path}
      expected_sqd_state = %Squad{squad | 
        timestamp: @stamp,
        position: nil,
        path: %Path{continuing_path | next_point: @next_point}
      }
      calculated_state = SquadSimulation.state_on(squad, @stamp)

      calculated_position = calculated_state.position
      assert %Squad{calculated_state | position: nil} == expected_sqd_state
      assert_in_delta @finish.x, calculated_position.x, 0.005
      assert_in_delta @finish.y, calculated_position.y, 0.005
    end
  end


  
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
