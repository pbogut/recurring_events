defmodule RecurringEvents.ByDay do
  @moduledoc """
  Handles `:by_day` rule
  """

  use RecurringEvents.Guards
  alias RecurringEvents.{Date, Daily}

  @doc """
  Applies `:by_day` rule to given date and returns enumerable.
  Depends on other rules it may create additional dates keep one provided
  or remove it. See tests for details.

  # Examples

      iex> RecurringEvents.ByDay.unfold(~D[2017-01-22],
      ...>       %{freq: :weekly, by_day: :monday})
      ...> |> Enum.take(10)
      [~D[2017-01-16]]

      iex> RecurringEvents.ByDay.unfold(~D[2017-01-22],
      ...>       %{freq: :monthly, by_day: :sunday})
      ...> |> Enum.take(10)
      [~D[2017-01-01], ~D[2017-01-08], ~D[2017-01-15], ~D[2017-01-22],
       ~D[2017-01-29]]

  """
  def unfold(date, %{by_day: day} = rules)
  when is_atom(day) do
    unfold(date, %{rules | by_day: [day]})
  end

  def unfold(date, rules) do
    case rules do
      %{by_day: _days, by_month: _} -> month_inflate(date, rules)
      %{by_day: _days, freq: :daily} -> filter(date, rules)
      %{by_day: _days, freq: :weekly} -> week_inflate(date, rules)
      %{by_day: _days, freq: :monthly} -> month_inflate(date, rules)
      %{by_day: _days, freq: :yearly} -> year_inflate(date, rules)
      _ -> [date]
    end
  end

  defp filter(dates, rules) when is_list(dates) do
    Stream.flat_map(dates, &filter(&1, rules))
  end

  defp filter(date, %{by_day: days}) do
    if is_week_day_in(date, days) do
      [date]
    else
      []
    end
  end

  defp year_inflate(date, %{by_day: days}) do
    year_start = %{date | day: 1, month: 1}
    year_end = %{date | day: 31, month: 12}
    inflate(year_start, year_end, days)
  end

  defp month_inflate(date, %{by_day: days}) do
    month_start = %{date | day: 1}
    month_end = %{date | day: Date.last_day_of_the_month(date)}
    inflate(month_start, month_end, days)
  end

  defp week_inflate(date, %{by_day: days} = rules) do
    week_start = week_start_date(date, rules)
    week_end = week_end_date(date, rules)
    inflate(week_start, week_end, days)
  end

  defp is_week_day_in(date, days) do
    Enum.any?(days, &Date.week_day(date) == &1)
  end

  defp inflate(start_date, stop_date, days) do
    start_date
    |> Daily.unfold(%{until: stop_date, freq: :daily})
    |> Stream.filter(&is_week_day_in(&1, days))
  end

  defp week_start_date(date, rules) do
    current_day = Date.week_day(date)
    start_day = week_start_day(rules)

    if current_day == start_day do
      date
    else
      date
      |> Date.shift_date(-1, :days)
      |> week_start_date(rules)
    end
  end

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

  defp week_start_day(%{week_start: start_day}), do: start_day
  defp week_start_day(%{}), do: :monday
end
