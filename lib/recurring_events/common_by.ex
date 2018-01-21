defmodule RecurringEvents.CommonBy do
  alias RecurringEvents.{Date, Daily}

  def filter(dates, filter_fun) when is_list(dates) do
    Stream.filter(dates, filter_fun)
  end

  def filter(date, filter_fun) do
    if filter_fun.(date) do
      [date]
    else
      []
    end
  end

  def inflate(date, %{by_month: _}, filter) do
    inflate_month(date, filter)
  end

  def inflate(date, %{freq: :weekly} = rules, filter) do
    inflate_week(date, rules, filter)
  end

  def inflate(date, %{freq: :monthly}, filter) do
    inflate_month(date, filter)
  end

  def inflate(date, %{freq: :yearly}, filter) do
    inflate_year(date, filter)
  end

  defp inflate_week(date, rules, filter) do
    week_start = week_start_date(date, rules)
    week_end = week_end_date(date, rules)
    inflate_period(week_start, week_end, filter)
  end

  defp inflate_month(date, filter) do
    month_start = %{date | day: 1}
    month_end = %{date | day: Date.last_day_of_the_month(date)}
    inflate_period(month_start, month_end, filter)
  end

  defp inflate_year(date, filter) do
    year_start = %{date | day: 1, month: 1}
    year_end = %{date | day: 31, month: 12}
    inflate_period(year_start, year_end, filter)
  end

  defp inflate_period(start_date, stop_date, filter) do
    start_date
    |> Daily.unfold(%{until: stop_date, freq: :daily})
    |> Stream.filter(filter)
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

  defp week_end_day(%{week_start: start_day}), do: Date.prev_week_day(start_day)
  defp week_end_day(%{}), do: :sunday

  defp week_start_day(%{week_start: start_day}), do: start_day
  defp week_start_day(%{}), do: :monday
end
