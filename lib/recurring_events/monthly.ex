defmodule RecurringEvents.Monthly do

  def unfold(date, %{freq: :monthly} = params, range) do
    {:ok, do_unfold(date, params, range)}
  end

  def unfold!(date, %{freq: :monthly} = params, range) do
    do_unfold(date, params, range)
  end

  defp do_unfold(date, %{} = params, {from_date, to_date}) do
    %{year: stop_year, month: stop_month} = get_stop_date(params, to_date)
    year = date.year
    month = date.month
    count = get_count(params)
    interval = get_interval(params)

    get_months({year, month}, {stop_year, stop_month}, interval)
    |> Enum.reduce_while([], fn {year, month}, acc ->
      if Enum.count(acc) == count do
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

  defp get_months({start_y, start_m}, {stop_y, stop_m}, step) do
    for year <- start_y..stop_y,
        month <- 1..12,
        rem((month + ((year - start_y) * 12)) - start_m, step) == 0,
        (year == start_y and month >= start_m and year < stop_y) or
        (year == start_y and month >= start_m and month < stop_m) or
        (year < stop_y and year > start_y) or
        (year == stop_y and month <= stop_m),
      do: {year, month}
  end

  defp get_stop_date(%{until: until}, to_date) when until < to_date, do: until
  defp get_stop_date(%{}, to_date), do: to_date

  defp get_interval(%{interval: interval}), do: interval
  defp get_interval(%{}), do: 1

  defp get_count(%{count: count}), do: count
  defp get_count(%{}), do: :infinity
end
