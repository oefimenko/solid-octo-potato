
defmodule App.User do
  @doc ~S"""
  Game User:
  room :: integer
  ip :: string
  squads :: [Game.Squad]
  in_game :: bool
  is_waiting :: bool
  """

  defstruct name: "Unknown",
            ip: nil,
            squads: nil,
            in_game: False,
            is_waiting: False,
            room: nil
  
  def generate_user(name, ip_addr) do
    squads = ["SkeletonSquad", "SpiderSquad"]
    %__MODULE__{name: name, squads: Enum.take_random(squads, 1), ip: ip_addr}
  end

  def test_user do
    squads = ["SkeletonSquad", "SpiderSquad"]
    %__MODULE__{name: "Test", squads: Enum.take_random(squads, 1)}
  end

end
