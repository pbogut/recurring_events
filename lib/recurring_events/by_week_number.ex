defmodule RecurringEvents.ByWeekNumber do
  @moduledoc """
  Handles `:by_week_number` rule
  """

  alias RecurringEvents.{Date, Guards, CommonBy}
  use Guards

  @doc """
  Applies `:by_week_number` rule to given date and returns enumerable.
  Depends on other rules it may create additional dates keep one provided
  or remove it. See tests for details.

  # Examples

      iex> RecurringEvents.ByWeekNumber.unfold(~D[2017-01-22],
      ...>       %{freq: :yearly, by_week_number: 3})
      ...> |> Enum.take(10)
      [~D[2017-01-16], ~D[2017-01-17], ~D[2017-01-18], ~D[2017-01-19] ,
       ~D[2017-01-20], ~D[2017-01-21], ~D[2017-01-22]]

  """
  def unfold(date, %{by_week_number: number} = rules, action)
      when is_integer(number) do
    unfold(date, %{rules | by_week_number: [number]}, action)
  end

  def unfold(date, rules, :filter) do
    week_start = Map.get(rules, :week_start, :monday)

    case rules do
      %{by_week_number: numbers} ->
        CommonBy.filter(date, &is_week_no_in(&1, numbers, week_start))

      _ ->
        [date]
    end
  end

  def unfold(date, rules, :inflate) do
    week_start = Map.get(rules, :week_start, :monday)

    case rules do
      %{by_week_number: numbers, freq: :monthly} ->
        CommonBy.inflate(date, rules, &is_week_no_in(&1, numbers, week_start))

      %{by_week_number: numbers, freq: :yearly} ->
        CommonBy.inflate(date, rules, &is_week_no_in(&1, numbers, week_start))

      _ ->
        [date]
    end
  end

  defp is_week_no_in(date, numbers, week_start) do
    Enum.any?(numbers, &is_week_no_eq(date, &1, week_start))
  end

  defp is_week_no_eq(date, number, week_start) when number > 0 do
    Date.week_number(date, week_start: week_start) == number
  end

  defp is_week_no_eq(date, number, week_start) when number < 0 do
    Date.week_number(date, reversed: true, week_start: week_start) == number
  end
end
