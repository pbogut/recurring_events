defmodule RecurringEvents do
  alias RecurringEvents.Freq.{Yearly, Monthly, Weekly, Daily}
  alias RecurringEvents.Date
  use RecurringEvents.Guards


  def unfold(_date, %{count: _, until: _}, _range) do
    {:error, "Can have either, count or until"}
  end

  def unfold(date, %{freq: freq} = params, range) when is_freq_valid(freq) do
    {:ok, unfold!(date, params, range)}
  end

  def unfold(_date, %{freq: _}, _range), do: {:error, "Frequency is invalid"}
  def unfold(_date, _rrule, _range), do: {:error, "Frequency is missing"}

  def unfold!(date, %{freq: freq} = params, range) do
    until = get_until_date(params, range)
    count = get_count(params)
    date
    |> get_freq_module(freq).unfold!(Map.put(params, :until, until))
    |> Stream.flat_map(fn date ->
      RecurringEvents.ByMonth.unfold(date, params, range)
    end)
    |> Stream.flat_map(fn date ->
      RecurringEvents.ByDay.unfold(date, params, range)
    end)
    |> drop_before(date)
    |> prepend(date)
    |> drop_after(until)
    |> drop_after(count)
  end

  defp drop_after(list, :infinite), do: list
  defp drop_after(list, count) when is_integer(count) do
    Stream.take(list, count)
  end
  defp drop_after(list, date) do
    Stream.take_while(list, fn date_ ->
      Date.compare(date, date_) != :lt
    end)
  end

  defp drop_before(list, date) do
    Stream.drop_while(list, fn date_ ->
      Date.compare(date, date_) != :lt
    end)
  end

  defp prepend(list, element) do
    Stream.concat([element], list)
  end

  defp get_count(%{count: count}), do: count
  defp get_count(%{}), do: :infinite

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
