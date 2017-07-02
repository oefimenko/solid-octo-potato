
defmodule Conn.Deserializer do
    
  def run do
    receive do
      {from, data} -> send(from, deserialize(data))
    end
    run()
  end

  def deserialize(<<0, _data :: binary>>) do
    IO.puts "Initail message captured"
  end
  
  def deserialize(<<1, ";", data :: binary>>) do
    raw = String.split(data, ";", trim: true)
    {1, %Game.Squad{
        side: Enum.at(raw, 0, nil),
        name: Enum.at(raw, 1, nil)
    }}
  end

  def deserialize(<<2, ";", data :: binary>>) do
    raw = String.split(data, ";", trim: true)
    {2, %Game.Squad{
        name: Enum.at(raw, 0, nil),
        path: Game.Path.deserialize(List.last(raw))
    }}
  end

  def deserialize(<<3, ";", data :: binary>>) do
    raw = String.split(data, ";", trim: true)
    {3, %Game.Squad{
        name: Enum.at(raw, 0, nil),
        formation: Enum.at(raw, 1, nil),
    }}
  end

  def deserialize(<<4, ";", data :: binary>>) do
    raw = String.split(data, ";", trim: true)
    {4, %Game.Squad{
        name: Enum.at(raw, 1, nil),
        offensive_skill: Enum.at(raw, 1, nil),
    }}
  end

end
