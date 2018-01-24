defmodule RecurringEvents.ByPump do
  alias RecurringEvents.{Date, Frequency}

  @rules [
    :by_month,
    :by_month_day,
    :by_week_number,
    :by_year_day,
    :by_day
  ]

  def inflate(date, rules, filter) when is_map(rules) do
    Enum.reduce(@rules, [date], fn rule, result ->
      case Map.get(rules, rule, :rule_unused) do
        :rule_unused -> result
        _ -> inflate(date, rule, rules) |> Enum.filter(filter)
      end
    end)
  end

  # any daily is already fully expaned
  def inflate(date, _any, %{freq: :daily}), do: [date]
  # if by_day then we have to expand to the maximum
  def inflate(date, :by_day, rules), do: do_inflate(date, rules)
  # any by_day or daily is already fully expanded so only filter needed
  def inflate(date, _any, %{by_day: _}), do: [date]
  def inflate(date, _any, %{freq: :daily}), do: [date]
  # if monthly then only filter by_month
  def inflate(date, :by_month, %{freq: :monthly}), do: [date]
  # if weehly then only filter by_week_number
  def inflate(date, :by_week_number, %{freq: :weekly}), do: [date]

  def inflate(date, :by_month_day, rules), do: do_inflate(date, rules)
  def inflate(date, :by_year_day, rules), do: do_inflate(date, rules)
  def inflate(date, :by_week_number, rules), do: do_inflate(date, rules)
  def inflate(date, :by_month, rules), do: inflate_by_month(date, rules)

  def inflate(date, _, _), do: [date]

  defp do_inflate(date, %{freq: :weekly} = rules) do
    inflate_week(date, rules)
  end

  defp do_inflate(date, %{freq: :monthly}) do
    inflate_month(date)
  end

  defp do_inflate(date, %{freq: :yearly}) do
    inflate_year(date)
  end

  defp inflate_week(date, rules) do
    week_start = week_start_date(date, rules)
    week_end = week_end_date(date, rules)
    inflate_period(week_start, week_end)
  end

  defp inflate_month(date) do
    month_start = %{date | day: 1}
    month_end = %{date | day: Date.last_day_of_the_month(date)}
    inflate_period(month_start, month_end)
  end

  defp inflate_year(date) do
    year_start = %{date | day: 1, month: 1}
    year_end = %{date | day: 31, month: 12}
    inflate_period(year_start, year_end)
  end

  defp inflate_period(start_date, stop_date) do
    start_date
    |> Frequency.unfold(%{until: stop_date, freq: :daily})
  end

  defp inflate_by_month(date, %{by_month: month}) when not is_list(month) do
    inflate_by_month(date, %{by_month: [month]})
  end

  defp inflate_by_month(date, %{by_month: months}) do
    Stream.map(months, fn month ->
      day = Date.last_day_of_the_month(%{date | month: month})
      %{date | month: month, day: min(day, date.day)}
    end)
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
