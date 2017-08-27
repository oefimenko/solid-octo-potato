
defmodule Conn.DeserializerPipe do
  
  def run(match) do
    receive do
      {data} -> match |> Rooms.Match.incoming(deserialize(data))
    end
    run(match)
  end

  def deserialize(<<1, 0, data :: binary>>) do
    raw = String.split(data, ";", trim: true)
    {:conn, Enum.at(raw, 0, nil)}
  end

  def deserialize(<<1, 1, _data :: binary>>) do
    {:ping}
  end

  def deserialize(<<1, 2, _data :: binary>>) do
    IO.puts "Initail message captured"
    {:init}
  end
  
  def deserialize(<<2, 1, ";", data :: binary>>) do
    raw = String.split(data, ";", trim: true)
    {:squad_state, %Game.Squad{
        side: Enum.at(raw, 0, nil),
        name: Enum.at(raw, 1, nil)
    }}
  end

  def deserialize(<<2, 2, ";", data :: binary>>) do
    raw = String.split(data, ";", trim: true)
    {:new_path, %Game.Squad{
        name: Enum.at(raw, 0, nil),
        path: Game.Path.deserialize(List.last(raw))
    }}
  end

  def deserialize(<<2, 3, ";", data :: binary>>) do
    raw = String.split(data, ";", trim: true)
    {:new_formation, %Game.Squad{
        name: Enum.at(raw, 0, nil),
        formation: Enum.at(raw, 1, nil),
    }}
  end

  def deserialize(<<2, 4, ";", data :: binary>>) do
    raw = String.split(data, ";", trim: true)
    {:skill_used, %Game.Squad{
        name: Enum.at(raw, 1, nil),
        offensive_skill: Enum.at(raw, 1, nil),
    }}
  end

  def deserialize({:latency, result}) do
    {:latency, result}
  end

  def deserialize({:sync_time, result}) do
    {:sync_time, result}
  end

end
