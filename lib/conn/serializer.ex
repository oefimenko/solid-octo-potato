
defmodule Conn.Serializer do
    
  def run do
    receive do
      {from, type, data} -> send(from, serialize(type, data))
    end
    run()
  end

  def serialize(0, {port, id_0, s_0, id_1, s_1, squads}) do
    s_squads = squads 
      |> Enum.map(fn(e) -> serialize(:squad, e) end) 
      |> Enum.join(";")
    "0;#{port};#{id_0};#{s_0};#{id_1};#{s_1};#{s_squads}"
  end

  def serialize(1, _squad) do
    ""
  end

  def serialize(2, squad) do
    serialize(:squad, squad) <> ":" <> serialize(:path, squad.path)
  end  

  def serialize(3, _squad) do
    ""
  end

  def serialize(4, _squad) do
    ""
  end

  # HELPERS

  def serialize(:squad, squad) do
    "#{squad.side}:#{squad.name}"
  end
  
  def serialize(:path, path) do
    Enum.map_join(path.points, ":", fn(p) -> serialize(:vector, p) end)
  end

  def serialize(:unit, _unit) do
    ""
  end

  def serialize(:vector, vector) do
    "#{vector.x}:#{vector.y}"
  end

end
