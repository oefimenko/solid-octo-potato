
defmodule Rooms.Lobby do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Public methods

  def players_list do
    GenServer.call(__MODULE__, {:read})
  end
    
  def login(user_name) do
    GenServer.cast(__MODULE__, {:add, user_name})
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

  def handle_cast({:add, user_name}, list) do
    {:noreply, %{list | user_name => %Game.User{name: user_name}}}
  end

  def handle_cast({:delete, user_name}, list) do
    {:noreply, Map.delete(list, user_name)}
  end

  def handle_cast({:match, user_name}, list) do
    user = %{Map.fetch(user_name) | is_waiting: true}
    {:noreply, %{list | user_name => user}}
  end

end
