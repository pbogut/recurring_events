defmodule RecurringEvents.DateTimex do
  alias RecurringEvents.Date

  def last_day_of_the_month(d), do: Date.last_day_of_the_month(d)
  def week_number(d, o), do: Date.week_number(d, o)
  def numbered_week_day(d, p, o), do: Date.numbered_week_day(d, p, o)
  def week_day(d), do: Date.week_day(d)
  def day_of_the_year(d), do: Date.day_of_the_year(d)
  def compare(d1, d2), do: Date.compare(d1, d2)
  def prev_week_day(d), do: Date.prev_week_day(d)

  @moduledoc """
  Helper module responsible for common date manipulations.
  This one is using Timex if avaliable
  """

  def shift_date(date, count, period) when period == :days do
    Timex.shift(date, days: count)
  end
  def shift_date(date, count, period) do
    Date.shift_date(date, count, period)
  end
end
