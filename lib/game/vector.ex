
defmodule Game.Vector do
  @doc ~S"""
  Game Vector:
    x :: float
    y :: float
  """

  defstruct x: 0, y: 0

  def serialize(nil) do
    ":"
  end

  def serialize(vector) do
    "#{vector.x}:#{vector.y}"  
  end
  
  def deserialize(raw) do
    points = raw.split(":")
    %__MODULE__{x: Enum.at(points, 0), y: Enum.at(points, 1)}
  end
  
end
