
defmodule Game.Simulation do
  use GenServer

  @frequency 5

  @doc ~S"""
  Game.Simulation:
  stash :: PID
  match :: PID
  squads :: MAP %{SquadName => Game.SquadSimulation}
  """
  defstruct stash: nil,
            match: nil,
            squads: %{},
            offset: 0

  def start_link(match, user_0, user_1, stash) do
    saved_state = stash |> Helpers.Stash.get(:simulation)
    params = {match, user_0, user_1, stash, saved_state}
    GenServer.start_link(__MODULE__, params, [])
  end

  def init({match, user_0, user_1, stash, nil}) do
    position = fn x1, x2, y1, y2 -> %Game.Vector{x: Enum.random(x1..x2) * 1000, y: Enum.random(y1..y2) * 1000} end
    user0_squads = Enum.map(user_0.squads, fn s -> %Game.Squad{s | position: position.(-8, -3, -4, 4) } end)
    user1_squads = Enum.map(user_1.squads, fn s -> %Game.Squad{s | position: position.(8, 3, -4, 4) } end)
    squads = user0_squads ++ user1_squads
    state = %__MODULE__{
        stash: stash,
        match: match,
        squads: Map.new(squads, fn s -> {s.name, Game.SquadSimulation.new(s)} end)
    }
    {:ok, state}
  end

  def init({match, _user_0, _user_1, stash, saved_state}) do
    state = %__MODULE__{
        stash: stash,
        match: match,
        squads: saved_state.squads
    }
    {:ok, state}
  end

  def terminate(_reason, state) do
    state.stash |> Helpers.Stash.set(:simulation, state)
  end

  def process(pid, data) do
    GenServer.cast(pid, data)
  end

  def set_time_offset(pid, offset) do
    GenServer.call(pid, {:set_offset, offset})
  end

  def start_simulation(pid) do
    Process.send_after(pid, {:simulate}, 5000)
  end

  #private
  def handle_info({:simulate}, state) do
    postpone_time = round(1000 / (map_size(state.squads) * @frequency))
    Enum.reduce(state.squads, 0, fn {_, s}, acc -> 
      Process.send_after(self(), {:sync_emit, s.last}, acc)
      acc + postpone_time
    end)
    Process.send_after(self(), {:simulate}, round(1000 / @frequency))
    {:noreply, state}
  end

  def handle_info({:sync_emit, squad}, state) do
    GenServer.cast(self(), {:squad_state, squad})
    {:noreply, state}
  end

  def handle_call({:set_offset, offset}, _from, state) do
    {:reply, {:ok}, %__MODULE__{state | offset: offset}}
  end

  def handle_cast({:init}, state) do
    state.match |> Rooms.Match.outcoming(
      {:init, Enum.map(Map.values(state.squads), fn s -> s.last end)}
    )
    {:noreply, state}
  end

  def handle_cast({:squad_state, squad}, state) do
    new_state = simulate_process(state, squad, :squad_state, [])
    {:noreply, new_state}
  end

  def handle_cast({:new_path, squad}, state) do
    new_state = simulate_process(state, squad, :new_path, [:path])
    {:noreply, new_state}
  end

  def handle_cast({:new_formation, squad}, state) do
    new_state = simulate_process(state, squad, :new_formation, [:formation, :speed])
    {:noreply, new_state}
  end

  def handle_cast({:skill_used, squad}, state) do
    new_state = simulate_process(state, squad, :skill_used, [])
    {:noreply, new_state}
  end

  # Simulation proccess and command propagation
  defp simulate_process(state, squad, type, fields) do
    predicted = state.squads[squad.name]
    |> Game.SquadSimulation.predicted_state_of(squad)
    
    update = fields 
    |> Enum.reduce(%{}, fn x, acc -> put_in(acc[x], Map.fetch!(predicted, x)) end)
    
    real = %Game.Squad{
      predicted | 
      version: predicted.version + squad.checksum, 
      checksum: squad.checksum
    }
    |> Map.merge(update)

    simulation = state.squads[squad.name] |> Game.SquadSimulation.update(real)
    state.match |> Rooms.Match.outcoming({type, real})
    %__MODULE__{state | squads: %{state.squads | squad.name => simulation}}
  end

end
