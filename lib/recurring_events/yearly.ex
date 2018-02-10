defmodule RecurringEvents.Yearly do
  @moduledoc """
  Handles `:yearly` frequency rule
  """

  alias RecurringEvents.Date

  @doc """
  Returns yearly stream of dates with respect to `:interval`, `:count` and
  `:until` rules. Only year form `:until` date is used, the rest of it is
  ignored.

  # Example

      iex> RecurringEvents.Yearly.unfold(~N[2017-11-22 10:11:11],
      ...>       %{freq: :yearly, until: ~N[2018-01-03 05:00:00]})
      ...> |> Enum.take(10)
      [~N[2017-11-22 10:11:11], ~N[2018-11-22 10:11:11]]

  """
  def unfold(date, %{freq: :yearly} = rules), do: do_unfold(date, rules)

  defp do_unfold(date, %{} = rules) do
    step = get_step(rules)
    count = get_count(rules)
    until_year = until_year(rules)

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
      fn _ -> nil end
    )
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

  defp add_count(%{exclude_date: dates}), do: dates |> Enum.count()
  defp add_count(%{}), do: 0

  defp get_count(%{count: count} = rules), do: count + add_count(rules)
  defp get_count(%{}), do: :infinity
end
