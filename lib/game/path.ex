
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
    path.points
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
    points_list = slice.({points, slice})
    %__MODULE__{points: points_list, total: length(points_list)}
  end

  def move_for(path, current, distance) do
    next_point = path.points |> Enum.at(path.next_point)
    move_for(path, current, next_point, distance, Vector.distance(current, next_point))
  end

  defp move_for(path, current, next, walk_distance, points_distance) when walk_distance <= points_distance do
    position = Vector.diff(next, current) 
            |> Vector.normalize
            |> Vector.multiply(walk_distance)
            |> Vector.add(current)
    {%__MODULE__{path | next_point: path.next_point}, position}
  end

  defp move_for(
    %__MODULE__{:next_point => point, :total => total} = path,
    current,
    next,
    walk_distance,
    points_distance
  ) when total - 1 <= point do
    {%__MODULE__{path | next_point: nil}, path.points |> Enum.at(path.total - 1)}
  end

  defp move_for(path, current, next, walk_distance, points_distance) when walk_distance > points_distance do
    upd_path = %__MODULE__{path | next_point: path.next_point + 1}
    next_point = upd_path.points |> Enum.at(upd_path.next_point)
    upd_walk_distance = walk_distance - points_distance
    upd_current = next
    upd_points_distance = Vector.distance(upd_current, next_point)
    move_for(upd_path, upd_current, next_point, upd_walk_distance, upd_points_distance)
  end


end
