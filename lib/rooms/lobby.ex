
defmodule Rooms.Lobby do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}}
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
    GenServer.call(__MODULE__, {:match, user_name})
  end

  def training(user_name) do 
    GenServer.call(__MODULE__, {:training, user_name})
  end


  # GenServer callbacks

  def handle_cast({:add, user_name}, state) do
    {:noreply, state |> Map.put(user_name, App.User.load_user(user_name))}
  end

  def handle_cast({:delete, user_name}, state) do
    {:noreply, Map.delete(state, user_name)}
  end

  def handle_call({:read}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:match, user_name}, _from, state) do
    waiting_user = Enum.find(state, nil, fn({_name, user}) -> user.is_waiting == true end)
    
    {state, port, hash} = if waiting_user != nil do
      {_name, waiting} = waiting_user
      {_hsh_1, hsh_2} = App.SessionManager.session_details(waiting.room)
      user_0 = %{waiting | is_waiting: false, in_game: true}
      user_1 = Map.fetch!(state, user_name)
               |> Map.put(:is_waiting, false)
               |> Map.put(:in_game, true)
               |> Map.put(:room, user_0.room)
               |> Map.put(:hash, hsh_2)

      Rooms.MatchSupervisor.start_link(user_0, user_1, user_0.room)
      {%{state | user_name => user_1, user_0.name => user_0}, user_0.room, hsh_2}
    else
      {port, hsh_1, _hsh_2} = App.SessionManager.start_session
      user = %{Map.fetch!(state, user_name) | is_waiting: true, room: port, hash: hsh_1}
      {%{state | user_name => user}, port, hsh_1}
    end
    
    {:reply, %{port: port, hash: hash}, state}
  end

  def handle_call({:training, user_name}, _from, state) do
    {port, hsh_1, _hsh_2} = App.SessionManager.start_session
    user_0 = Map.fetch!(state, user_name)
             |> Map.put(:is_waiting, false)
             |> Map.put(:in_game, true)
             |> Map.put(:room, port)
             |> Map.put(:hash, hsh_1)
    
    {:ok, _pid} = Rooms.MatchSupervisor.start_link(user_0, port)
    state = %{state | user_name => user_0}
    {:reply, %{port: port, hash: hsh_1}, state}
  end

end
