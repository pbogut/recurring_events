defmodule RecurringEvents.Monthly do
  alias RecurringEvents.Date

  def unfold(date, %{freq: :monthly} = params, range) do
    {:ok, do_unfold(date, params, range)}
  end

  def unfold!(date, %{freq: :monthly} = params, range) do
    do_unfold(date, params, range)
  end

  defp do_unfold(date, %{} = params, {from_date, to_date}) do
    %{year: stop_year, month: stop_month} = get_stop_date(params, to_date)
    max = {stop_year, stop_month}
    year = date.year
    month = date.month
    count = get_count(params)
    interval = get_interval(params)

    get_months_stream({year, month}, interval)
    |> Enum.reduce_while([], fn {year, month} = cur, acc ->
      if should_stop_generating(acc, count, cur, max) do
        {:halt, acc}
      else
        {:cont, acc ++ [%{date | year: year, month: month}]}
      end
    end)
    |> Enum.drop_while(fn date ->
      date.year < from_date.year or
      (date.year == from_date.year and date.month < from_date.month)
    end)
  end

  defp should_stop_generating(list, count, {year, month}, {stop_y, stop_m}) do
    Enum.count(list) == count or
      year > stop_y or
      (year == stop_y and month > stop_m)
  end

  defp get_months_stream({start_y, start_m}, step) do
    Stream.iterate({start_y, start_m}, fn {year, month} ->
      {y, m, _d} = Date.shift_date({year, month, 1}, step, :months)
      {y, m}
    end)
  end

  defp get_stop_date(%{until: until}, to_date) when until < to_date, do: until
  defp get_stop_date(%{}, to_date), do: to_date

  defp get_interval(%{interval: interval}), do: interval
  defp get_interval(%{}), do: 1

  defp get_count(%{count: count}), do: count
  defp get_count(%{}), do: :infinity
end
