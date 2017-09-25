
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
            squads: [],
            in_game: False,
            is_waiting: False,
            room: nil,
            hash: nil
  
  def load_user(name) do
    %__MODULE__{name: name, squads: [Game.Squad.init(name)]}
  end

  def test_user do
    load_user("Test")
  end

end
