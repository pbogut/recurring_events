defmodule RecurringEvents.ByDay do
  use RecurringEvents.Guards
  alias RecurringEvents.Date

  def unfold(date, %{by_day: day} = params, range)
  when is_atom(day) do
    unfold(date, %{params | by_day: [day]}, range)
  end

  def unfold(date, %{by_day: _days, by_month: _} = params, _range) do
    month_inflate(date, params)
  end

  def unfold(date, %{by_day: _days, freq: :daily} = params, _range) do
    filter(date, params)
  end

  def unfold(date, %{by_day: _days, freq: :weekly} = params, _range) do
    week_inflate(date, params)
  end

  def unfold(date, %{by_day: _days, freq: :monthly} = params, _range) do
    month_inflate(date, params)
  end

  def unfold(date, %{by_day: _days, freq: :yearly} = params, _range) do
    year_inflate(date, params)
  end

  def unfold(date, %{}, _range) do
    [date]
  end

  defp filter(dates, params) when is_list(dates) do
    Stream.flat_map(dates, &filter(&1, params))
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

  defp week_inflate(date, %{by_day: days} = params) do
    week_start = week_start_date(date, params)
    week_end = week_end_date(date, params)
    inflate(week_start, week_end, days)
  end

  defp is_week_day_in(date, days) do
    days
    |> Enum.any?(fn day -> Date.week_day(date) == day end)
  end

  defp inflate(start_date, stop_date, days) do
    start_date
    |> RecurringEvents.Freq.Daily.unfold!(%{until: stop_date, freq: :daily})
    |> Stream.filter(fn date ->
      is_week_day_in(date, days)
    end)
  end

  defp week_start_date(date, params) do
    current_day = Date.week_day(date)
    start_day = week_start_day(params)

    if current_day == start_day do
      date
    else
      date
      |> Date.shift_date(-1, :days)
      |> week_start_date(params)
    end
  end

  defp week_end_date(date, params) do
    current_day = Date.week_day(date)
    end_day = week_end_day(params)

    if current_day == end_day do
      date
    else
      date
      |> Date.shift_date(1, :days)
      |> week_end_date(params)
    end
  end

  defp week_end_day(%{week_start: start_day}) do
    Date.prev_week_day(start_day)
  end
  defp week_end_day(%{}), do: :sunday

  defp week_start_day(%{week_start: start_day}), do: start_day
  defp week_start_day(%{}), do: :monday
end
