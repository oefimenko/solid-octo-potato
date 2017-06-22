
defmodule App.User do
  @doc ~S"""
  Game User:
  side :: integer
  ip :: string
  squads :: [Game.Squad]
  in_game :: bool
  is_waiting :: bool
  """

  defstruct name: "Unknown",
            ip: nil,
            side: nil,
            squads: nil,
            in_game: False,
            is_waiting: False
  
  def generate_user(name, ip_addr) do
    squads = ["Skeletons", "Spiders"]
    %__MODULE__{name: name, squads: Enum.take_random(squads, 1), ip: ip_addr}
  end

end
