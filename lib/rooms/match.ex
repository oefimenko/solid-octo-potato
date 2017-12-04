
defmodule Rooms.Match do
  use GenServer

  @doc ~S"""
  Rooms.Match:
  user_0 :: App.User
  user_1 :: App.User
  serializer :: pid
  simulation :: pid
  ready :: MapSet
  connection :: pid
  rules :: Map
  """
  defstruct user_0: nil,
            user_1: nil,
            serializer: nil,
            simulation: nil,
            ready: MapSet.new,
            rules: %{
              conn: {:async, :ack},
              latency: {:latency}, # special rules
              sync_time: {:sync_time}, # special rules
              init: {:sync, :ack},
              match_start: {:async, :ack},
              surrender: {:sync, :ack},
              squad_state: {:async, :no_ack},
              new_path: {:async, :ack},
              follow_path: {:async, :ack},
              path_purge: {:async, :ack},
              bind: {:async, :ack},
              unbind: {:async, :ack},
              new_formation: {:async, :ack},
              skill_used: {:async, :ack},
              close_attack: {:async, :ack},
              ranged_attack: {:async, :ack},
              match_finish: {:async, :ack}
            }

  def child_spec(stash, user_0, user_1, port) do 
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [stash, user_0, user_1, port]}
    }
  end

  def start_link(stash, user_0, user_1, l_port) do
    GenServer.start_link(__MODULE__, {stash, user_0, user_1, l_port}, [])
  end

  def incoming(pid, data) do
    GenServer.cast(pid, {:incoming, data})
  end

  def outcoming(pid, data) do
    GenServer.cast(pid, {:outcoming, data})
  end

  # Genserver Callbacks
  def init({stash, user_0, user_1, port}) do
    deserializer = spawn_link(Conn.DeserializerPipe, :run, [self()])
    {:ok, conn} = Conn.UDP.start_link(deserializer, port, stash, user_0.hash, user_1.hash)
    serializer = spawn_link(Conn.SerializerPipe, :run, [conn])
    {:ok, simulation} = Game.Simulation.start_link(self(), user_0, user_1, stash)

    state = %__MODULE__{
        user_0: user_0,
        user_1: user_1,
        serializer: serializer,
        simulation: simulation
    }
    {:ok, state}
  end

  def handle_cast({:incoming, data}, state) do
    new_state = process_incoming(data, state)
    {:noreply, new_state}
  end

  def handle_cast({:outcoming, data}, state) do
    new_state = process_outcoming(data, state)
    {:noreply, new_state}
  end

  # Private

  defp process_incoming({{:conn, user_name}, _h}, state) do
    new_state = %__MODULE__{state | ready: MapSet.put(state.ready, user_name)}
    if MapSet.size(new_state.ready) >= 2 do
      state.serializer |> send({:latency, state.rules.latency, {}})
    end
    new_state
  end

  defp process_incoming({:latency, result}, state) do
    {_hash, offset} = result |> Enum.max_by(fn({_k, v}) -> v end)
    state.simulation |> Game.Simulation.set_time_offset(offset)
    state.serializer |> send({:sync_time, state.rules.sync_time, result})
    state
  end

  defp process_incoming({:sync_time, _}, state) do
    state.simulation |> Game.Simulation.process({:init})
    state
  end

  defp process_incoming({{_type, squad} = data, hash}, state) do
    name = cond do
      state.user_0.hash == hash -> state.user_0.name
      state.user_1.hash == hash -> state.user_1.name
      true -> ":Wrong_Hash"
    end
    if String.starts_with?(squad.name, name) do
      state.simulation |> Game.Simulation.process(data)
    end
    state
  end

  defp process_outcoming({:init, data}, state) do
    state.serializer |> send({:init, state.rules.init, data})
    start_time = Helpers.Time.future(:string, 5, :seconds)
    state.serializer |> send({:match_start, state.rules.match_start, start_time})
    state.simulation |> Game.Simulation.start_simulation
    state
  end

  defp process_outcoming({type, data}, state) do
    state.serializer |> send({type, Map.fetch!(state.rules, type), data})
    state
  end

end
