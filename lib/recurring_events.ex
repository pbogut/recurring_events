defmodule RecurringEvents do
  alias RecurringEvents.Freq.{Yearly, Monthly, Weekly, Daily}
  use RecurringEvents.Guards


  def unfold(_date, %{count: _, until: _}, _range) do
    {:error, "Can have either, count or until"}
  end
  def unfold(date, %{freq: freq} = params, range) when is_freq_valid(freq) do
    get_freq_module(freq).unfold(date, params, range)
  end
  def unfold(_date, %{freq: _}, _range), do: {:error, "Frequency is invalid"}
  def unfold(_date, _rrule, _range), do: {:error, "Frequency is missing"}


  defp get_freq_module(:yearly), do: Yearly
  defp get_freq_module(:monthly), do: Monthly
  defp get_freq_module(:weekly), do: Weekly
  defp get_freq_module(:daily), do: Daily

end
