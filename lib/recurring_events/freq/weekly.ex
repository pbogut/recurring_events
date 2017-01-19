defmodule RecurringEvents.Freq.Weekly do
  alias RecurringEvents.Date

  def unfold(date, %{freq: :weekly} = params, range) do
    {:ok, do_unfold(date, params, range)}
  end

  def unfold!(date, %{freq: :weekly} = params, range) do
    do_unfold(date, params, range)
  end

  defp do_unfold(date, %{} = params, {from_date, to_date}) do
    stop_date = get_stop_date(params, to_date)
    count = get_count(params)
    interval = get_interval(params)

    get_weeks_stream(date, interval)
    |> Enum.reduce_while([], fn date, acc ->
      if Enum.count(acc) == count or :gt == Date.compare(date, stop_date) do
        {:halt, acc}
      else
        {:cont, acc ++ [date]}
      end
    end)
    |> Enum.drop_while(fn date ->
      date < from_date
    end)
  end

  defp get_weeks_stream(date, step) do
    Stream.iterate(date, fn next_date ->
      Date.shift_date(next_date, step * 7, :days)
    end)
  end

  defp get_stop_date(%{until: until}, to_date) do
    case Date.compare(until, to_date) do
      :lt -> until
      _ -> to_date
    end
  end
  defp get_stop_date(%{}, to_date), do: to_date

  defp get_interval(%{interval: interval}), do: interval
  defp get_interval(%{}), do: 1

  defp get_count(%{count: count}), do: count
  defp get_count(%{}), do: :infinity
end
