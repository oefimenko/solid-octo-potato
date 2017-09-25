
defmodule App.SessionManager do
  use GenServer

  @lower_port 22001
  @upper_port 32001

  @hsh_length 16
  @lower Enum.map(?a..?z, &to_string([&1]))
  @upper Enum.map(?A..?Z, &to_string([&1]))
  @digit Enum.map(?0..?9, &to_string([&1]))
  @all @lower ++ @upper ++ @digit

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{next: @lower_port, details: %{}}}
  end

  # public api

  def start_session do
    GenServer.call(__MODULE__, {:session})
  end

  def close_session(port) do
    GenServer.call(__MODULE__, {:close, port})
  end

  def session_details(port) do
    GenServer.call(__MODULE__, {:details, port})
  end

  # GenServer callbacks

  def handle_call({:session}, _from, state) do
    result = {next, hsh1, hsh2} = {state.next, generate_hash(), generate_hash()}
    details = Map.put(state.details, next, {hsh1, hsh2})
    new_state = %{state | next: calculate_next(details), details: details } 
    {:reply, result, new_state}
  end

  def handle_call({:details, _from, port}, state) do
    {:reply, Map.fetch(state.details, port), state}
  end

  def handle_call({:close, port}, _from, state) do
    {:reply, true, %{state | details: Map.delete(state.details, port)}}
  end

  # Private

  defp generate_hash do
    Enum.map(1..@hsh_length, fn _ -> Enum.random(@all) end)
    |> Enum.join
  end

  defp calculate_next(details) do
    Enum.find(@lower_port..@upper_port, fn port -> not Enum.member?(Map.keys(details), port) end)
  end

end
