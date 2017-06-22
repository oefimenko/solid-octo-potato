
defmodule Rooms.Lobby do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Public methods

  def players_list do
    GenServer.call(__MODULE__, {:read})
  end
    
  def login(user_name, ip) do
    GenServer.cast(__MODULE__, {:add, user_name, ip})
  end
  
  def logout(user_name) do
    GenServer.cast(__MODULE__, {:delete, user_name})
  end

  def match(user_name) do 
    GenServer.cast(__MODULE__, {:match, user_name})
  end

  # GenServer callbacks
  
  def init(:ok) do
    # Received 2nd argument from start_link, returns :ok and initial state
    {:ok, %{}}
  end

  def handle_call({:read}, _from, list) do
    {:reply, list, list}
  end

  def handle_cast({:add, user_name, ip}, list) do
    {:noreply, %{list | user_name => App.User.generate_user(user_name, ip)}}
  end

  def handle_cast({:delete, user_name}, list) do
    {:noreply, Map.delete(list, user_name)}
  end

  def handle_cast({:match, user_name}, list) do
    waiting_user = Enum.find(list, nil, fn(user) -> user.is_waiting == true end)
    state = if waiting_user != nil do
      user_0 =  %{waiting_user | is_waiting: false, side: 0, in_game: true}
      user_1 =  %{Map.fetch(list, user_name) | is_waiting: false, side: 1, in_game: true}
      Rooms.Match.start_link(user_0, user_1)
      %{list | user_name => user_1, user_0.name => user_0}
    else
      user = %{Map.fetch(list, user_name) | is_waiting: true}
      %{list | user_name => user}
    end
    {:noreply, state}
  end

end
