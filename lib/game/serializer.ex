
defmodule Game.Serializer do
    
  def run do
      receive do
        {from, type, data} -> send(from, serialize(type, data))
      end
      run()
  end

  def serialize(:squad, squad) do
    "#{squad.side}.#{squad.name}"
  end

end