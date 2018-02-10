defmodule RecurringEvents.Monthly do
  @moduledoc """
  Handles `:monthly` frequency rule
  """

  alias RecurringEvents.Date

  @doc """
  Returns monthly stream of dates with respect to `:interval`, `:count` and
  `:until` rules. Time and day in date provided as `:until` is ignored.

  # Example

      iex> RecurringEvents.Monthly.unfold(~N[2017-01-22 10:11:11],
      ...>       %{freq: :monthly, until: ~N[2017-02-03 05:00:00]})
      ...> |> Enum.take(10)
      [~N[2017-01-22 10:11:11], ~N[2017-02-22 10:11:11]]

  """
  def unfold(date, %{freq: :monthly} = rules), do: do_unfold(date, rules)

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

  defp add_count(%{exclude_date: dates}), do: dates |> Enum.count()
  defp add_count(%{}), do: 0

  defp get_count(%{count: count} = rules), do: count + add_count(rules)
  defp get_count(%{}), do: :infinity
end
