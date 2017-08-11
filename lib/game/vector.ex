
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
  
  def distance(vector_1, vector_2) do
    :math.pow(vector_1.x - vector_2.x, 2) + :math.pow(vector_1.y - vector_2.y, 2) |> :math.sqrt
  end

  def normilize(%__MODULE__{:x => 0, :y => 0}) do
    %__MODULE__{x: 0, y: 0}
  end

  def normalize(vector) do
    m = magnitute(vector)
    %__MODULE__{x: vector.x / m, y: vector.y / m}
  end

  def magnitute(vector) do
    :math.pow(vector.x, 2) + :math.pow(vector.y, 2) |> :math.sqrt
  end

  def add(vector_1, vector_2) do
    %__MODULE__{x: vector_1.x + vector_2.x, y: vector_1.y + vector_2.y}
  end

  def diff(vector_1, vector_2) do
    %__MODULE__{x: vector_1.x - vector_2.x, y: vector_1.y - vector_2.y}
  end

  def multiply(vector, mlp) do
    %__MODULE__{x: vector.x * mlp, y: vector.y * mlp}
  end
end
