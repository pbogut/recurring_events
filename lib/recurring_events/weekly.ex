defmodule RecurringEvents.Weekly do
  alias RecurringEvents.Date

  def unfold(date, %{freq: :weekly} = params) do
    {:ok, do_unfold(date, params)}
  end

  def unfold!(date, %{freq: :weekly} = params) do
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
    next_date = Date.shift_date(date, step * iteration, :weeks)
    acc = {date, iteration + 1}
    {[next_date], acc}
  end

  defp until_reached(_date, :forever), do: false
  defp until_reached(date, until_date) do
    Date.compare(date, until_date) == :gt
  end

  defp until_date(%{until: until_date} = params) do
    until_date
    |> week_end_date(params)
  end
  defp until_date(%{}), do: :forever

  defp week_end_date(date, params) do
    current_day = Date.week_day(date)
    end_day = week_end_day(params)

    if current_day == end_day do
      date
    else
      date
      |> Date.shift_date(1, :days)
      |> week_end_date(params)
    end
  end

  defp week_end_day(%{week_start: start_day}) do
    Date.prev_week_day(start_day)
  end
  defp week_end_day(%{}), do: :friday

  defp get_step(%{interval: interval}), do: interval
  defp get_step(%{}), do: 1

  defp get_count(%{count: count}), do: count
  defp get_count(%{}), do: :infinity
end
