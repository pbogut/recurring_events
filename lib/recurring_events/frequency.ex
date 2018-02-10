defmodule RecurringEvents.Frequency do
  @moduledoc """
  Handles `:frequency` frequency rule
  """

  alias RecurringEvents.Date

  @doc """
  Returns frequency stream of dates with respect to `:interval`, `:count` and
  `:until` rules.

  # Example

      iex> RecurringEvents.Frequency.unfold(~N[2017-01-22 10:11:11],
      ...>       %{freq: :daily, until: ~N[2017-01-23 15:00:00]})
      ...> |> Enum.take(10)
      [~N[2017-01-22 10:11:11], ~N[2017-01-23 10:11:11]]

  """
  def unfold(date, %{freq: _frequency} = rules) do
    do_unfold(date, rules)
  end

  defp do_unfold(date, %{freq: frequency} = rules) do
    step = get_step(rules)
    count = get_count(rules)
    until_date = until_date(rules)
    step_by = get_step_by(frequency)

    Stream.resource(
      fn -> {date, 0} end,
      fn {date, iteration} ->
        {[next_date], _} = next_result = next_iteration(date, step, iteration, step_by)

        cond do
          iteration == count -> {:halt, nil}
          until_reached(next_date, until_date) -> {:halt, nil}
          true -> next_result
        end
      end,
      fn _ -> nil end
    )
  end

  defp get_step_by(:daily), do: :days
  defp get_step_by(:hourly), do: :hours
  defp get_step_by(:minutely), do: :minutes
  defp get_step_by(:secondly), do: :seconds

  defp next_iteration(date, step, iteration, step_by) do
    next_date = Date.shift_date(date, step * iteration, step_by)
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

  defp add_count(%{exclude_date: dates}), do: dates |> Enum.count()
  defp add_count(%{}), do: 0

  defp get_count(%{count: count} = rules), do: count + add_count(rules)
  defp get_count(%{}), do: :infinity
end
