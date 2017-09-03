
defmodule Conn.SerializerPipe do
      
  def run(connection) do
    receive do
      {type, rules, data} -> connection |> Conn.UDP.send(rules, serialize(type, data))
    end
    run(connection)
  end

  # Connection message
  def serialize(:conn, _) do
    "10" <> ";"
  end

  # latency message
  def serialize(:latency, _) do
    "11" <> ";"
  end

  # Sync time message
  def serialize(:sync_time, offsets) do
    {"12" <> ";", offsets}
  end

  # Init message
  def serialize(:init, {id_0, id_1, squads}) do
    s_squads = squads 
      |> Enum.map(fn(e) -> Game.Squad.serialize(e) end) 
      |> Enum.join(";")
      
    "13;#{id_0};0;#{id_1};1;#{s_squads}"
  end

  # Match start
  def serialize(:match_start, start_time) do
    "14;#{start_time}"
  end

  # Squad State message
  def serialize(:squad_state, squad) do
    "21" <> ";" <> Game.Squad.serialize(squad)
  end

  # Path provided
  def serialize(:new_path, squad) do
    "22" <> ";" <> Game.Squad.serialize(squad)
  end  

  # Formation message
  def serialize(:new_formation, squad) do
    "23" <> ";" <> Game.Squad.serialize(squad)
  end

  # Skill message
  def serialize(:skill_used, squad) do
    "24" <> ";" <> Game.Squad.serialize(squad)
  end

end
