
defmodule Game.Simulation do
  use GenServer

  def start_link(match, user_0, user_1, stash) do
    saved_state = stash |> Helpers.Stash.get(:connection)
    params = {match, user_0, user_1, stash}
    GenServer.start_link(__MODULE__, params, [])
  end

  def init({match, user_0, user_1, stash}) do
    # pass
  end

end