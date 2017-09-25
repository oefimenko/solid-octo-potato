
defmodule Rooms.MatchSupervisor do
  use Supervisor

  def start_link(user_0, l_port) do
    user_1 = App.User.test_user
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, [], [])
    {:ok, stash} = Supervisor.start_child(sup, Helpers.Stash.child_spec)
    {:ok, match} = Supervisor.start_child(sup, Rooms.Match.child_spec(stash, user_0, user_1, l_port))
    Rooms.Match.incoming(match, {{:conn, user_1.name}, "hash"})
    result
  end

  def start_link(user_0, user_1, l_port) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, [], [])
    {:ok, stash} = Supervisor.start_child(sup, Helpers.Stash.child_spec)
    Supervisor.start_child(sup, Rooms.Match.child_spec(stash, user_0, user_1, l_port))
    result
  end

  def init(_arg) do
    Supervisor.init([], strategy: :rest_for_one)
  end

end
