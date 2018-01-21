defmodule RecurringEvents.ByWeekNumber do
  @moduledoc """
  Handles `:by_week_number` rule
  """

  alias RecurringEvents.{Date, Guards, Daily}
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
  def unfold(date, %{by_week_number: number} = rules)
      when is_integer(number) do
    unfold(date, %{rules | by_week_number: [number]})
  end

  def unfold(date, rules) do
    week_start = Map.get(rules, :week_start, :monday)
    with_week_start = Map.put(rules, :week_start, week_start)

    # rules |> Map.put(:week_st
    case with_week_start do
      %{by_week_number: _days, by_month: _} -> filter(date, with_week_start)
      %{by_week_number: _days, freq: :daily} -> filter(date, with_week_start)
      %{by_week_number: _days, freq: :weekly} -> filter(date, with_week_start)
      %{by_week_number: _days, freq: :monthly} -> month_inflate(date, with_week_start)
      %{by_week_number: _days, freq: :yearly} -> year_inflate(date, with_week_start)
      _ -> [date]
    end
  end

  defp filter(date, %{by_week_number: numbers, week_start: week_start}) do
    if Enum.any?(numbers, &is_week_no_eq(date, &1, week_start)) do
      [date]
    else
      []
    end
  end

  defp year_inflate(date, %{by_week_number: numbers, week_start: week_start}) do
    year_start = %{date | day: 1, month: 1}
    year_end = %{date | day: 31, month: 12}
    inflate(year_start, year_end, numbers, week_start)
  end

  defp month_inflate(date, %{by_week_number: numbers, week_start: week_start}) do
    month_start = %{date | day: 1}
    month_end = %{date | day: Date.last_day_of_the_month(date)}
    inflate(month_start, month_end, numbers, week_start)
  end

  defp inflate(start_date, stop_date, numbers, week_start) do
    start_date
    |> Daily.unfold(%{until: stop_date, freq: :daily})
    |> Stream.filter(&is_week_no_in(&1, numbers, week_start))
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
