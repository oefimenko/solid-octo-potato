
defmodule Game.Squad do
  @doc ~S"""
  Game Sqaud:
  side :: int
  name :: string
  health :: float
  damage :: float
  last_attack :: float
  position :: Game.Vector
  rotation :: float
  path :: Game.Path
  local_aim :: Game.Vector
  speed :: Game.Vector
  bounds :: Game.Vector
  formation :: string
  offensive_skill :: string
  defensive_skill :: string
  """

  defstruct side: nil,
            name: nil,
            health: nil,
            damage: nil,
            last_attack: 0.0,
            position: nil,
            rotation: nil,
            path: nil,
            local_aim: nil,
            speed: nil,
            bounds: nil,
            formation: nil,
            offensive_skill: nil,
            defensive_skill: nil

end
