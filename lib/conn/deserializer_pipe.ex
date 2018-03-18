
defmodule Conn.DeserializerPipe do
  
  def run(match) do
    receive do
      {data} -> match |> Rooms.Match.incoming(deserialize(data))
      {data, hash} -> match |> Rooms.Match.incoming({deserialize(data), hash})
    end
    run(match)
  end

  def deserialize(<<1, 0, data :: binary>>) do
    raw = String.split(data, ";", trim: true)
    {:conn, Enum.at(raw, 0, nil)}
  end

  def deserialize({:latency, result}) do
    {:latency, result}
  end

  def deserialize({:sync_time, result}) do
    {:sync_time, result}
  end

  def deserialize(<<1, 3, _data :: binary>>) do
    {:init}
  end

  def deserialize(<<1, 4, _data :: binary>>) do
    {:match_start}
  end

  def deserialize(<<2, 1, ";", data :: binary>>) do
    raw = String.split(data, ";", trim: true)
    {version, _} = Integer.parse(Enum.at(raw, 2, nil))
    {:squad_state, %Game.Squad{
        owner: Enum.at(raw, 0, nil),
        name: Enum.at(raw, 1, nil),
        version: Enum.at(raw, 2, nil),
    }}
  end

  def deserialize(<<2, 2, ";", data :: binary>>) do
    raw = String.split(data, ";", trim: true)
    {version, _} = Integer.parse(Enum.at(raw, 2, nil))
    {timestamp, _} = Integer.parse(Enum.at(raw, 3, nil))
    {:new_path, %Game.Squad{
        name: Enum.at(raw, 0, nil),
        path: Game.Path.deserialize(Enum.at(raw, 1, nil)),
        version: version,
        timestamp: timestamp
    }}
  end

  def deserialize(<<2, 3, ";", data :: binary>>) do
    raw = String.split(data, ";", trim: true)
    {version, _} = Integer.parse(Enum.at(raw, 2, nil))
    {timestamp, _} = Integer.parse(Enum.at(raw, 3, nil))
    {:new_formation, %Game.Squad{
        name: Enum.at(raw, 0, nil),
        formation: Enum.at(raw, 1, nil),
        version: version,
        timestamp: timestamp
    }}
  end

  def deserialize(<<2, 4, ";", data :: binary>>) do
    raw = String.split(data, ";", trim: true)
    {version, _} = Integer.parse(Enum.at(raw, 2, nil))
    {timestamp, _} = Integer.parse(Enum.at(raw, 3, nil))
    {:skill_used, %Game.Squad{
        name: Enum.at(raw, 1, nil),
        offensive_skill: Enum.at(raw, 1, nil),
        version: version,
        timestamp: timestamp
    }}
  end

end
