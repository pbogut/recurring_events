defmodule RecurringEvents.Date do

  def shift_date(%{year: year, month: month, day: day} = date, count, :days) do
    {new_year, new_month, new_day} =
      shift_date({year, month, day}, count, :days)
    %{date | year: new_year, month: new_month, day: new_day}
  end

  def shift_date({_year, _month, _day} = date, count, :days) do
    date
      |> :calendar.date_to_gregorian_days
      |> Kernel.+(count)
      |> :calendar.gregorian_days_to_date
  end

  def shift_date(%{year: year, month: month, day: day} = date, count, :months) do
    {new_year, new_month, new_day} =
      shift_date({year, month, day}, count, :months)
    %{date | year: new_year, month: new_month, day: new_day}
  end

  def shift_date({year, month, day}, count, :months) do
    months = (year * 12) + (month - 1) + count

    new_year = div(months, 12)
    new_month = rem(months, 12) + 1

    last_day = :calendar.last_day_of_the_month(new_year, new_month)
    new_day = min(day, last_day)

    {new_year, new_month, new_day}
  end
end
