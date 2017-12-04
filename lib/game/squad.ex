
defmodule Game.Squad do
  
  @supported_squads [:skeletons, :spiders]
  
  @doc ~S"""
  Game Sqaud:
  version :: int
  checksum :: int
  timestamp :: int
  owner :: string
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

  defstruct version: 0,
            checksum: 0,
            timestamp: 0,
            owner: "",
            name: nil,
            type: nil,
            health: nil,
            damage: nil,
            last_attack: 0,
            position: nil,
            rotation: nil,
            path: nil,
            local_aim: nil,
            speed: nil,
            bounds: nil,
            formation: nil,
            offensive_skill: nil,
            defensive_skill: nil

  def init(:skeletons, name) do
    %__MODULE__{type: "SkeletonSquad", name: name <> "Skeletons", owner: name}
  end
  
  def init(:spiders, name) do
    %__MODULE__{type: "SpiderSquad", name: name <> "Spiders", owner: name}
  end

  def init(name) do
    init(Enum.random(@supported_squads), name)
  end

  def serialize(squad) do
    "#{squad.type}:" <>                                 #0
    "#{squad.owner}:" <>                                #1
    "#{squad.name}:" <>                                 #2
    "#{squad.health}:" <>                               #3
    "#{squad.damage}:" <>                               #4
    "#{squad.last_attack}:" <>                          #5
    "#{Game.Vector.serialize(squad.position)}:" <>      #6-7
    "#{squad.rotation}:" <>                             #8
    "#{squad.formation}:" <>                            #9
    "#{squad.offensive_skill}:" <>                      #10
    "#{squad.defensive_skill}:" <>                      #11
    "#{Game.Vector.serialize(squad.speed)}:" <>         #12-13
    "#{Game.Vector.serialize(squad.bounds)}:" <>        #14-15
    "#{Game.Vector.serialize(squad.local_aim)}:" <>     #16-17
    "#{Game.Path.serialize(squad.path)}"                #18-end
  end
  
end
