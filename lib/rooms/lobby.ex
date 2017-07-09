
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

  def training(user_name) do 
    GenServer.cast(__MODULE__, {:training, user_name})
  end


  # GenServer callbacks
  
  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:read}, _from, list) do
    {:reply, list, list}
  end

  def handle_cast({:add, user_name, ip}, list) do
    IO.inspect({"Login", user_name, ip})
    {:noreply, Map.put(list, user_name, App.User.generate_user(user_name, ip))}
  end

  def handle_cast({:delete, user_name}, list) do
    {:noreply, Map.delete(list, user_name)}
  end

  def handle_cast({:match, user_name}, list) do
    IO.inspect({"match", user_name})
    waiting_user = Enum.find(list, nil, fn({_name, user}) -> user.is_waiting == true end)
    state = if waiting_user != nil do
      {_name, waiting} = waiting_user
      user_0 = %{waiting | is_waiting: false, side: 0, in_game: true}
      user_1 = %{Map.fetch!(list, user_name) | is_waiting: false, side: 1, in_game: true}
      port = Enum.random(22001..32001)
      Rooms.Match.start_link(user_0, user_1, port)
      %{list | user_name => user_1, user_0.name => user_0}
    else
      user = %{Map.fetch!(list, user_name) | is_waiting: true}
      %{list | user_name => user}
    end
    {:noreply, state}
  end

  def handle_cast({:training, user_name}, list) do
    IO.inspect({"training", user_name})
    user_0 =  %{Map.fetch!(list, user_name) | is_waiting: false, side: 1, in_game: true}
    port = Enum.random(22001..32001)
    Rooms.Match.start_link(user_0, App.User.test_user, port)
    state = %{list | user_name => user_0}
    {:noreply, state}
  end

end
