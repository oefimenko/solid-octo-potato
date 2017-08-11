
defmodule Game.Path do
  alias Game.Vector
  
  @doc ~S"""
  Game Path:
  points :: [Game.Vector]
  next_point :: int
  """
  defstruct points: nil,
            next_point: 0,
            total: 0

  def serialize(nil) do
    ""
  end

  def serialize(path) do
    path 
    |> Enum.map(fn(e) -> Vector.serialize(e) end)
    |> Enum.join(":")
  end

  def deserialize(raw) do
    points = raw 
             |> String.split(":", trim: true)
             |> Enum.map(fn(x) -> String.to_integer(x) end)
    slice = fn 
        ({[x, y | rest], fun}) -> fun.({rest, [%Vector{x: x, y: y}], fun})
        ({[x, y | rest], list, fun}) -> fun.({rest, list ++ [%Vector{x: x, y: y}], fun})
        ({[], list, _fun}) -> list
    end
    slice.({points, slice})
  end

  def move_for(path, current, distance) do
    traveled =  current |> Vector.distance(path.points |> Enum.at(path.next_point))
    move_for(step_frw(path), traveled, path.points |> Enum.at(path.next_point), distance)
  end

  defp move_for(%__MODULE__{:next_point => point, :total => total} = path, _t, current, _d) when point >= total - 1 do
    {path, current}
  end

  defp move_for(path, traveled, current, distance) when traveled < distance do
    new_traveled = traveled + current |> Vector.distance(path.points |> Enum.at(path.next_point))
    move_for(step_frw(path), new_traveled, path.points |> Enum.at(path.next_point), distance)
  end

  defp move_for(path, traveled, current, distance) when traveled == distance do
    {path, current}
  end

  defp move_for(path, traveled, current, distance) when traveled > distance do
    previous = path.points |> Enum.at(path.next_point - 1)
    left = Vector.distance(previous, current) - traveled + distance
    position = Vector.diff(current, previous) 
                |> Vector.normalize
                |> Vector.multiply(left)
                |> Vector.add(previous)

    {%__MODULE__{path | next_point: path.next_point - 1}, position}
  end

  defp step_frw(path) do
    next_point = if path.next_point < path.total - 1 do
      path.next_point + 1
    else
      path.total - 1
    end
    %__MODULE__{path | next_point: next_point}
  end

end
