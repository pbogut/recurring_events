defmodule RecurringEvents.ByMonthDay do
  @moduledoc """
  Handles `:by_month_day` rule
  """

  use RecurringEvents.Guards
  alias RecurringEvents.{Date, Daily}

  @doc """
  Applies `:by_month_day` rule to given date and returns enumerable.
  Depends on other rules it may create additional dates keep one provided
  or remove it. See tests for details.

  # Examples

     iex> RecurringEvents.ByMonthDay.unfold(~D[2017-01-22],
     ...>       %{freq: :weekly, by_month_day: [18, 31]})
     ...> |> Enum.take(10)
     [~D[2017-01-18]]

     iex> RecurringEvents.ByMonthDay.unfold(~D[2017-01-22],
     ...>       %{freq: :monthly, by_month_day: [1, -1]})
     ...> |> Enum.take(10)
     [~D[2017-01-01], ~D[2017-01-31]]

  """
  def unfold(date, %{by_month_day: day} = rules) when not is_list(day) do
    unfold(date, %{rules | by_month_day: [day]})
  end

  def unfold(date, rules) do
    case rules do
      %{by_month_day: _days, by_day: _} -> filter(date, rules)
      %{by_month_day: _days, by_month: _} -> month_inflate(date, rules)
      %{by_month_day: _days, freq: :daily} -> filter(date, rules)
      %{by_month_day: _days, freq: :weekly} -> week_inflate(date, rules)
      %{by_month_day: _days, freq: :monthly} -> month_inflate(date, rules)
      %{by_month_day: _days, freq: :yearly} -> year_inflate(date, rules)
      _ -> [date]
    end
  end

  defp filter(dates, rules) when is_list(dates) do
    Stream.flat_map(dates, &filter(&1, rules))
  end

  defp filter(date, %{by_month_day: days}) do
    if is_month_day_in(date, days) do
      [date]
    else
      []
    end
  end

  defp is_month_day_in(date, days) do
    Enum.any?(days, &is_month_day_eq(date, &1))
  end

  defp is_month_day_eq(%{day: date_day}, day) when day > 0 do
    date_day == day
  end

  defp is_month_day_eq(%{day: date_day} = date, day) when day < 0 do
    date_day - (Date.last_day_of_the_month(date) + 1) == day
  end

  defp year_inflate(date, %{by_month_day: days}) do
    year_start = %{date | day: 1, month: 1}
    year_end = %{date | day: 31, month: 12}
    inflate(year_start, year_end, days)
  end

  defp month_inflate(date, %{by_month_day: days}) do
    month_start = %{date | day: 1}
    month_end = %{date | day: Date.last_day_of_the_month(date)}
    inflate(month_start, month_end, days)
  end

  defp week_inflate(date, %{by_month_day: days} = rules) do
    week_start = week_start_date(date, rules)
    week_end = week_end_date(date, rules)
    inflate(week_start, week_end, days)
  end

  defp inflate(start_date, stop_date, days) do
    start_date
    |> Daily.unfold(%{until: stop_date, freq: :daily})
    |> Stream.filter(&is_month_day_in(&1, days))
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
