defmodule RecurringEvents.ByChecker do
  alias RecurringEvents.Guards
  use Guards

  @date_helper Application.get_env(:recurring_events, :date_helper_module)

  @rules [
    :by_month,
    :by_month_day,
    :by_hour,
    :by_minute,
    :by_second,
    :by_year_day,
    :by_week_number,
    :by_day
  ]

  def check(date, rules) do
    Enum.reduce(@rules, true, fn rule, result ->
      result and
        case Map.get(rules, rule, :rule_unused) do
          :rule_unused -> true
          _ -> do_check(date, rule, rules)
        end
    end)
  end

  defp do_check(date, :by_day, rules) do
    is_week_day_in(date, rules)
  end

  defp do_check(date, :by_month, rules) do
    is_month_in(date, rules)
  end

  defp do_check(date, :by_month_day, rules) do
    is_month_day_in(date, rules)
  end

  defp do_check(date, :by_week_number, rules) do
    week_start = Map.get(rules, :week_start, :monday)
    is_week_no_in(date, Map.put(rules, :week_start, week_start))
  end

  defp do_check(date, :by_year_day, rules) do
    is_year_day_in(date, rules)
  end

  defp do_check(date, :by_hour, %{by_hour: hours}) do
    date.hour in hours
  end

  defp do_check(date, :by_minute, %{by_minute: minutes}) do
    date.minute in minutes
  end

  defp do_check(date, :by_second, %{by_second: seconds}) do
    date.second in seconds
  end

  defp is_year_day_in(date, %{by_year_day: numbers}) do
    Enum.any?(numbers, &is_year_day(date, &1))
  end

  defp is_year_day(date, number) when number > 0 do
    @date_helper.day_of_the_year(date) == number
  end

  defp is_year_day(%{year: year} = date, number) when number < 0 do
    last_day = if(:calendar.is_leap_year(year), do: 366, else: 365)
    -(last_day - @date_helper.day_of_the_year(date) + 1) == number
  end

  def is_week_no_in(date, %{by_week_number: numbers, week_start: week_start}) do
    Enum.any?(numbers, &is_week_no_eq(date, &1, week_start))
  end

  defp is_week_no_eq(date, number, week_start) when number > 0 do
    @date_helper.week_number(date, week_start: week_start) == number
  end

  defp is_week_no_eq(date, number, week_start) when number < 0 do
    @date_helper.week_number(date, reversed: true, week_start: week_start) == number
  end

  defp is_month_day_in(date, %{by_month_day: days}) do
    Enum.any?(days, &is_month_day_eq(date, &1))
  end

  defp is_month_day_eq(%{day: date_day}, day) when day > 0 do
    date_day == day
  end

  defp is_month_day_eq(%{day: date_day} = date, day) when day < 0 do
    date_day - (@date_helper.last_day_of_the_month(date) + 1) == day
  end

  defp is_month_in(date, %{by_month: months}) do
    date.month in months
  end

  defp is_week_day_in(date, %{by_day: days, by_month: _}) do
    Enum.any?(days, &is_week_day_eq(date, &1, :month))
  end

  defp is_week_day_in(date, %{by_day: days, freq: :monthly}) do
    Enum.any?(days, &is_week_day_eq(date, &1, :month))
  end

  defp is_week_day_in(date, %{by_day: days, freq: :yearly}) do
    Enum.any?(days, &is_week_day_eq(date, &1, :year))
  end

  defp is_week_day_in(date, %{by_day: days}) do
    Enum.any?(days, &is_week_day_eq(date, &1))
  end

  defp is_week_day_eq(date, {_, week_day}) do
    is_week_day_eq(date, week_day)
  end

  defp is_week_day_eq(date, week_day) do
    @date_helper.week_day(date) == week_day
  end

  defp is_week_day_eq(date, {n, _} = week_day, period) when n < 0 do
    @date_helper.numbered_week_day(date, period, :backward) == week_day
  end

  defp is_week_day_eq(date, {n, _} = week_day, period) when n > 0 do
    @date_helper.numbered_week_day(date, period, :foreward) == week_day
  end

  defp is_week_day_eq(date, week_day, _period) when is_atom(week_day) do
    is_week_day_eq(date, week_day)
  end
end
