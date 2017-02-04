defmodule RecurringEvents.Monthly do
  alias RecurringEvents.Date

  def unfold(date, %{freq: :monthly} = params) do
    {:ok, do_unfold(date, params)}
  end

  def unfold!(date, %{freq: :monthly} = params) do
    do_unfold(date, params)
  end

  defp do_unfold(date, %{} = params) do
    step = get_step(params)
    count = get_count(params)
    until_date = until_date(params)

    Stream.resource(
      fn -> {date, 0} end,
      fn {date, iteration} ->
        {[next_date], _} = next_result = next_iteration(date, step, iteration)
        cond do
          iteration == count -> {:halt, nil}
          until_reached(next_date, until_date) -> {:halt, nil}
          true -> next_result
        end
      end,
      fn _ -> nil end)
  end

  defp next_iteration(date, step, iteration) do
    next_date = Date.shift_date(date, step * iteration, :months)
    acc = {date, iteration + 1}
    {[next_date], acc}
  end

  defp until_reached(_date, :forever), do: false
  defp until_reached(date, until_date) do
    Date.compare(date, until_date) == :gt
  end

  defp until_date(%{until: until_date}) do
    last_day = Date.last_day_of_the_month(until_date)
    %{until_date | day: last_day}
  end
  defp until_date(%{}), do: :forever

  defp get_step(%{interval: interval}), do: interval
  defp get_step(%{}), do: 1

  defp get_count(%{count: count}), do: count
  defp get_count(%{}), do: :infinity
end
