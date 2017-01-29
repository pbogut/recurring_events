defmodule RecurringEvents.Date do

  @week_days [
    :monday,
    :tuesday,
    :wednesday,
    :thursday,
    :friday,
    :saturday,
    :sunday
  ]

  def shift_date(%{year: year, month: month, day: day} = date, count, period) do
    {new_year, new_month, new_day} =
      shift_date({year, month, day}, count, period)
    %{date | year: new_year, month: new_month, day: new_day}
  end

  def shift_date({_year, _month, _day} = date, count, :days) do
    date
      |> :calendar.date_to_gregorian_days
      |> Kernel.+(count)
      |> :calendar.gregorian_days_to_date
  end

  def shift_date({_year, _month, _day} = date, count, :weeks) do
    shift_date(date, count * 7, :days)
  end

  def shift_date({year, month, day}, count, :months) do
    months = (year * 12) + (month - 1) + count

    new_year = div(months, 12)
    new_month = rem(months, 12) + 1

    last_day = :calendar.last_day_of_the_month(new_year, new_month)
    new_day = min(day, last_day)

    {new_year, new_month, new_day}
  end

  def shift_date({year, month, day}, count, :years) do
    {year + count, month, day}
  end

  def last_day_of_the_month(%{year: year, month: month}) do
    :calendar.last_day_of_the_month(year, month)
  end

  def last_day_of_the_month({year, month, _day}) do
    :calendar.last_day_of_the_month(year, month)
  end

  def week_day(%{year: year, month: month, day: day}) do
    week_day({year, month, day})
  end

  def week_day({_year, _month, _day} = date) do
    @week_days |> Enum.at(:calendar.day_of_the_week(date) - 1)
  end

  def shift_week_day(day, shift) do
    day_no =
      @week_days
      |> Enum.find_index(fn d -> d == day end)
      |> Kernel.+(shift)
      |> rem(7)

    Enum.at(@week_days, day_no)
  end

  def next_week_day(day) do
    shift_week_day(day, 1)
  end

  def prev_week_day(day) do
    shift_week_day(day, -1)
  end

  def compare(%{year: y1, month: m1, day: d1},
              %{year: y2, month: m2, day: d2}) do
    compare({y1, m1, d1}, {y2, m2, d2})
  end

  def compare({y1, m1, d1}, {y2, m2, d2}) do
    cond do
      y1 == y2 and m1 == m2 and d1 == d2
        -> :eq
      y1 > y2 or (y1 == y2 and m1 > m2) or (y1 == y2 and m1 == m2 and d1 > d2)
        -> :gt
      true
        -> :lt
    end
  end
end
