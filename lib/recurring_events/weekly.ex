defmodule RecurringEvents.Weekly do
  @moduledoc """
  Handles `:weekly` frequency rule
  """

  alias RecurringEvents.Date

  @doc """
  Returns weekly stream of dates with respect to `:interval`, `:count` and
  `:until` rules. Date provided as `:until` is used to figure out week
  in which it occurs, exact date is not respected.

  # Example

      iex> RecurringEvents.Weekly.unfold(~N[2017-01-22 10:11:11],
      ...>       %{freq: :weekly, until: ~N[2017-01-23 15:00:00]})
      ...> |> Enum.take(10)
      [~N[2017-01-22 10:11:11], ~N[2017-01-29 10:11:11]]

  """
  def unfold(date, %{freq: :weekly} = rules), do: do_unfold(date, rules)

  defp do_unfold(date, %{} = rules) do
    step = get_step(rules)
    count = get_count(rules)
    until_date = until_date(rules)

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
      fn _ -> nil end
    )
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

  defp until_date(%{until: until_date} = rules) do
    until_date
    |> week_end_date(rules)
  end

  defp until_date(%{}), do: :forever

  defp week_end_date(date, rules) do
    current_day = Date.week_day(date)
    end_day = week_end_day(rules)

    if current_day == end_day do
      date
    else
      date
      |> Date.shift_date(1, :days)
      |> week_end_date(rules)
    end
  end

  defp week_end_day(%{week_start: start_day}) do
    Date.prev_week_day(start_day)
  end

  defp week_end_day(%{}), do: :sunday

  defp get_step(%{interval: interval}), do: interval
  defp get_step(%{}), do: 1

  defp add_count(%{exclude_date: dates}), do: dates |> Enum.count()
  defp add_count(%{}), do: 0

  defp get_count(%{count: count} = rules), do: count + add_count(rules)
  defp get_count(%{}), do: :infinity
end
