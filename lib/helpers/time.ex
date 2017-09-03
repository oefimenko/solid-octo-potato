
defmodule Helpers.Time do

  def current(:int) do
    :os.system_time(:micro_seconds)
  end

  def current(:string) do
    current(:int) |> stringify
  end

  def future(:int, offset, :seconds) do
    current(:int) + offset * 1000000
  end

  def future(:int, offset, :micro_seconds) do
    current(:int) + offset
  end

  def future(:string, offset, :seconds) do
    future(:int, offset, :seconds) |> stringify
  end

  def future(:string, offset, :micro_seconds) do
    future(:int, offset, :micro_seconds) |> stringify
  end

  def delta(:micro_seconds, time_1, time_2) do
    time_2 - time_1
  end

  def delta(:seconds, time_1, time_2) do
    (time_2 - time_1) / 1000000
  end

  defp stringify(time) do
    time
    |> Integer.to_string()
    |> String.pad_trailing(16, "0")
  end

end
