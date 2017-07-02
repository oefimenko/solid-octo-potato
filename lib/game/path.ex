
defmodule Game.Path do
  @doc ~S"""
  Game Path:
  points :: [Game.Vector]
  """

  defstruct points: nil

  def serialize(nil) do
    ""
  end

  def serialize(path) do
    path 
    |> Enum.map(fn(e) -> Game.Vector.serialize(e) end)
    |> Enum.join(":")
  end

  def deserialize(raw) do
    points = raw 
             |> String.split(":", trim: true)
             |> Enum.map(fn(x) -> String.to_integer(x) end)
    slice = fn 
        ({[x, y | rest], fun}) -> fun.({rest, [%Game.Vector{x: x, y: y}], fun})
        ({[x, y | rest], list, fun}) -> fun.({rest, list ++ [%Game.Vector{x: x, y: y}], fun})
        ({[], list, _fun}) -> list
    end
    slice.({points, slice})
  end

end
