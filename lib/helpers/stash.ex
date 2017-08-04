
defmodule Helpers.Stash do
  use Agent
  
  ### External API

  def child_spec do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

  def start_link do 
    Agent.start_link(fn -> %{} end)
  end 

  def set(bucket, key, value) do 
    Agent.update(bucket, &Map.put(&1, key, value))
  end 

  def get(stash, key) do
    Agent.get(stash, &Map.get(&1, key))
  end

end
