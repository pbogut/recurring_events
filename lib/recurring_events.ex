defmodule RecurringEvents do
  alias RecurringEvents.Freq.{Yearly, Monthly, Weekly, Daily}
  alias RecurringEvents.Date
  use RecurringEvents.Guards


  def unfold(_date, %{count: _, until: _}, _range) do
    {:error, "Can have either, count or until"}
  end
  def unfold(date, %{freq: freq} = params, range) when is_freq_valid(freq) do
    until = get_until_date(params, range)
    {:ok, dates} = get_freq_module(freq).unfold(date, Map.put(params, :until, until))
    {:ok, RecurringEvents.ByMonth.unfold(dates, params, range)}
  end
  def unfold(_date, %{freq: _}, _range), do: {:error, "Frequency is invalid"}
  def unfold(_date, _rrule, _range), do: {:error, "Frequency is missing"}

  defp get_until_date(%{until: until_date}, {_from, to_date}) do
    if Date.compare(until_date, to_date) == :gt do
      to_date
    else
      until_date
    end
  end
  defp get_until_date(%{}, {_from, to}), do: to

  defp get_freq_module(:yearly), do: Yearly
  defp get_freq_module(:monthly), do: Monthly
  defp get_freq_module(:weekly), do: Weekly
  defp get_freq_module(:daily), do: Daily

end
