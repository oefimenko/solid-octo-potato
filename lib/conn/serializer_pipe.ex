
defmodule Conn.SerializerPipe do
      
  def run(connection) do
    receive do
      {type, rules, data} -> connection |> Conn.UDP.send(rules, serialize(type, data))
    end
    run(connection)
  end

  # Connection message
  def serialize(:conn, _) do
    <<1, 0>>
  end

  # latency message
  def serialize(:latency, _) do
    <<1, 1>>
  end

  # Sync time message
  def serialize(:sync_time, offsets) do
    {<<1, 2>>, offsets}
  end

  # Init message
  def serialize(:init, squads) do
    s_squads = squads 
      |> Enum.map(fn(e) -> Game.Squad.serialize(e) end) 
      |> Enum.join(";")
      
    <<1, 3>> <> "#{s_squads}"
  end

  # Match start
  def serialize(:match_start, start_time) do
    <<1, 4>> <> "#{start_time}"
  end

  # Squad State message
  def serialize(:squad_state, squad) do
    <<2, 1>> <> Game.Squad.serialize(squad)
  end

  # Path provided
  def serialize(:new_path, squad) do
    <<2, 2>> <> Game.Squad.serialize(squad)
  end  

  # Formation message
  def serialize(:new_formation, squad) do
    <<2, 3>> <> Game.Squad.serialize(squad)
  end

  # Skill message
  def serialize(:skill_used, squad) do
    <<2, 4>> <> Game.Squad.serialize(squad)
  end

end
