
defmodule Conn.Serializer do
    
  def run do
    receive do
      {from, type, data} -> send(from, serialize(type, data))
    end
    run()
  end

  # Init message
  def serialize(0, {port, id_0, s_0, id_1, s_1, squads}) do
    s_squads = squads 
      |> Enum.map(fn(e) -> Game.Squad.serialize(e) end) 
      |> Enum.join(";")
      
    "0;#{port};#{id_0};#{s_0};#{id_1};#{s_1};#{s_squads}"
  end

  # State message
  def serialize(1, _squad) do
    ""
  end

  # Path provided
  def serialize(2, squad) do
    "2" <> ";" <> Game.Squad.serialize(squad)
  end  

  # Formation message
  def serialize(3, squad) do
    "3" <> ";" <> Game.Squad.serialize(squad)
  end

  # Skill message
  def serialize(4, squad) do
    "4" <> ";" <> Game.Squad.serialize(squad)
  end

end
