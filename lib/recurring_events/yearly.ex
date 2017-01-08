defmodule RecurringEvents.Yearly do

  def unfold(date, %{freq: :yearly} = params, range) do
    {:ok, do_unfold(date, params, range)}
  end

  def unfold!(date, %{freq: :yearly} = params, range) do
    do_unfold(date, params, range)
  end

  defp do_unfold(date, %{} = params, {from_date, to_date}) do
    %{year: stop_year} = get_stop_date(params, to_date)
    year = date.year
    count = get_count(params)
    interval = get_interval(params)

    get_years(year, stop_year, interval)
    |> Enum.reduce_while([], fn year, acc ->
      if Enum.count(acc) == count do
        {:halt, acc}
      else
        {:cont, acc ++ [%{date | year: year}]}
      end
    end)
    |> Enum.drop_while(fn date -> date.year < from_date.year end)
  end

  defp get_years(start, stop, step) do
    for year <- start..stop,
      rem(year - start, step) == 0,
      do: year
  end

  defp get_stop_date(%{until: until}, to_date) when until < to_date, do: until
  defp get_stop_date(%{}, to_date), do: to_date

  defp get_interval(%{interval: interval}), do: interval
  defp get_interval(%{}), do: 1

  defp get_count(%{count: count}), do: count
  defp get_count(%{}), do: :infinity
end
