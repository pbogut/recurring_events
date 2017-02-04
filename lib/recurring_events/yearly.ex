defmodule RecurringEvents.Yearly do
  alias RecurringEvents.Date

  def unfold(date, %{freq: :yearly} = params) do
    {:ok, do_unfold(date, params)}
  end

  def unfold!(date, %{freq: :yearly} = params) do
    do_unfold(date, params)
  end

  defp do_unfold(date, %{} = params) do
    step = get_step(params)
    count = get_count(params)
    until_year = until_year(params)

    Stream.resource(
      fn -> {date, 0} end,
      fn {date, iteration} ->
        {[next_date], _} = next_result = next_iteration(date, step, iteration)
        cond do
          iteration == count -> {:halt, nil}
          next_date.year > until_year -> {:halt, nil}
          true -> next_result
        end
      end,
      fn _ -> nil end)
  end

  defp next_iteration(date, step, iteration) do
    next_date = Date.shift_date(date, step * iteration, :years)
    acc = {date, iteration + 1}
    {[next_date], acc}
  end

  defp until_year(%{until: %{year: year}}), do: year
  defp until_year(%{}), do: :forever

  defp get_step(%{interval: interval}), do: interval
  defp get_step(%{}), do: 1

  defp get_count(%{count: count}), do: count
  defp get_count(%{}), do: :infinity
end
