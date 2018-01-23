defmodule RecurringEvents.Daily do
  @moduledoc """
  Handles `:daily` frequency rule
  """

  alias RecurringEvents.Date

  @doc """
  Returns daily stream of dates with respect to `:interval`, `:count` and
  `:until` rules. 

  # Example

      iex> RecurringEvents.Daily.unfold(~N[2017-01-22 10:11:11],
      ...>       %{freq: :daily, until: ~N[2017-01-24 05:00:00]})
      ...> |> Enum.take(10)
      [~N[2017-01-22 10:11:11], ~N[2017-01-23 10:11:11]]

  """
  def unfold(date, %{freq: :daily} = rules), do: do_unfold(date, rules)

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
    next_date = Date.shift_date(date, step * iteration, :days)
    acc = {date, iteration + 1}
    {[next_date], acc}
  end

  defp until_reached(_date, :forever), do: false

  defp until_reached(date, until_date) do
    Date.compare(date, until_date) == :gt
  end

  defp until_date(%{until: until_date}), do: until_date
  defp until_date(%{}), do: :forever

  defp get_step(%{interval: interval}), do: interval
  defp get_step(%{}), do: 1

  defp get_count(%{count: count}), do: count
  defp get_count(%{}), do: :infinity
end
