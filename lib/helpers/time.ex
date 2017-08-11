
defmodule Helpers.Time do

  def current(:int) do
    :os.system_time(:micro_seconds)
  end

  def current(:string) do
    time = :os.system_time(:micro_seconds)
           |> Integer.to_string()
           |> String.pad_trailing(16, "0")
  end

  def delta(:micro_seconds, time_1, time_2) do
    time_2 - time_1
  end

  def delta(:seconds, time_1, time_2) do
    (time_2 - time_1) / 1000000
  end

end
