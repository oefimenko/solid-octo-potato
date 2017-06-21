
defmodule Game.User do
  @doc ~S"""
  Game User:
  side :: integer
  squads :: [Game.Squad]
  in_game :: bool
  is_waiting :: bool
  """

  defstruct name: "Unknown", 
            side: nil, 
            squads: nil, 
            in_game: False, 
            is_waiting: False

end
