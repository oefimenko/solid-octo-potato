
defmodule Rooms.MatchSupervisor do
  use Supervisor

  def start_link(user_0, user_1, l_port) do
    result = {:ok, sup } = Supervisor.start_link(__MODULE__, [], [])
    {:ok, stash} = Supervisor.start_child(sup, Helpers.Stash.child_spec)
    Supervisor.start_child(sup, Rooms.Match.child_spec(stash, user_0, user_1, l_port))
    result
  end

  def init(_arg) do
    Supervisor.init([], strategy: :rest_for_one)
  end

end
