
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
    raw = String.split(data, ":", trim: true)
    {1, %Game.Squad{
        side: Enum.at(raw, 0, nil),
        name: Enum.at(raw, 1, nil)
    }}
  end

  def deserialize(<<2, ";", data :: binary>>) do
    raw = String.split(data, ":", trim: true)
    {2, %Game.Squad{
        side: Enum.at(raw, 0, nil),
        name: Enum.at(raw, 1, nil),
        path: deserialize(:path, Enum.slice(raw, 2..-1))
    }}
  end

  def deserialize(<<3, ";", data :: binary>>) do
    raw = String.split(data, ":", trim: true)
    {3, %Game.Squad{
        side: Enum.at(raw, 0, nil),
        name: Enum.at(raw, 1, nil),
        formation: Enum.at(raw, 2, nil),
    }}
  end

  def deserialize(<<4, ";", data :: binary>>) do
    raw = String.split(data, ":", trim: true)
    {4, %Game.Squad{
        side: Enum.at(raw, 0, nil),
        name: Enum.at(raw, 1, nil),
        offensive_skill: Enum.at(raw, 2, nil),
    }}
  end

  def deserialize(:path, path) do
    slice = fn 
        ({[x, y | rest], fun}) -> fun.({path, [%Game.Vector{x: x, y: y}], fun})
        ({[x, y | rest], list, fun}) -> fun.({path, list ++ [%Game.Vector{x: x, y: y}], fun})
        ({[], list, fun}) -> list
    end
    %Game.Path{points: slice.({path, slice})}
  end

  def deserialize(:unit, unit) do
    %Game.Unit{}
  end

  def deserialize(:vector, vector) do
    %Game.Vector{
        x: Enum.at(vector, 0),
        x: Enum.at(vector, 1),
    }
  end
end
