
defmodule Game.User do
  @doc ~S"""
  Game User:
  side :: integer
  squads :: [Game.Squad]
  """

  defstruct side: nil, squads: nil

end
