defmodule RecurringEvents.ByPump do
  alias RecurringEvents.{Date, Frequency}

  def inflate(date, %{by_day: _} = rules, filter), do: do_inflate(date, rules, filter)
  def inflate(date, %{by_month_day: _} = rules, filter), do: do_inflate(date, rules, filter)
  def inflate(date, %{by_year_day: _} = rules, filter), do: do_inflate(date, rules, filter)
  def inflate(date, %{by_week_number: _} = rules, filter), do: do_inflate(date, rules, filter)
  def inflate(date, %{by_month: _} = rules, filter), do: inflate_by_month(date, rules, filter)
  def inflate(date, _rules, _filter), do: [date]

  def do_inflate(date, %{freq: :weekly} = rules, filter) do
    inflate_week(date, rules, filter)
  end

  def do_inflate(date, %{freq: :monthly}, filter) do
    inflate_month(date, filter)
  end

  def do_inflate(date, %{freq: :yearly}, filter) do
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
    |> Frequency.unfold(%{until: stop_date, freq: :daily})
    |> Stream.filter(filter)
  end

  defp inflate_by_month(date, %{by_month: month}, filter) when not is_list(month) do
    inflate_by_month(date, %{by_month: [month]}, filter)
  end

  defp inflate_by_month(date, %{by_month: months}, filter) do
    Stream.map(months, fn month ->
      day = Date.last_day_of_the_month(%{date | month: month})
      %{date | month: month, day: min(day, date.day)}
    end)
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
