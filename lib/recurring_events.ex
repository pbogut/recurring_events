defmodule RecurringEvents do
  alias RecurringEvents.{Date, Guards,
                         Yearly, Monthly, Weekly, Daily,
                         ByMonth, ByDay}
  use Guards

  def unfold(_date, %{count: _, until: _}) do
    raise ArgumentError, message: "Can have either, count or until"
  end
  def unfold(date, %{freq: freq} = rules) when is_freq_valid(freq) do
    do_unfold(date, rules)
  end
  def unfold(_date, %{freq: _}) do
    raise ArgumentError, message: "Frequency is invalid"
  end
  def unfold(_date, _rrule) do
    raise ArgumentError, message: "Frequency is required"
  end

  @doc """
  Returns list of recurring events based on date and rules

  # Example

      iex> RecurringEvents.take(~D[2015-09-13], %{freq: :monthly}, 4)
      [~D[2015-09-13], ~D[2015-10-13], ~D[2015-11-13], ~D[2015-12-13]]

  """
  def take(date, rules, count) do
    date |> do_unfold(rules) |> Enum.take(count)
  end

  defp do_unfold(date, %{freq: freq} = rules) do
    date
    |> get_freq_module(freq).unfold(rules)
    |> Stream.flat_map(&ByMonth.unfold &1, rules)
    |> Stream.flat_map(&ByDay.unfold &1, rules)
    |> drop_before(date)
    |> prepend(date)
    |> drop_after(rules)
  end

  defp drop_before(list, date) do
    Stream.drop_while(list, &Date.compare(date, &1) != :lt)
  end

  defp drop_after(list, %{until: date}) do
    Stream.take_while(list, &Date.compare(date, &1) != :lt)
  end
  defp drop_after(list, %{count: count}), do: Stream.take(list, count)
  defp drop_after(list, %{}), do: list

  defp prepend(list, element), do: Stream.concat([element], list)

  defp get_freq_module(:yearly), do: Yearly
  defp get_freq_module(:monthly), do: Monthly
  defp get_freq_module(:weekly), do: Weekly
  defp get_freq_module(:daily), do: Daily
end
