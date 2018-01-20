defmodule RecurringEvents.Date do
  @moduledoc """
  Helper module responsible for common date manipulations.
  """

  @time {0, 0, 0}
  @week_days [
    :monday,
    :tuesday,
    :wednesday,
    :thursday,
    :friday,
    :saturday,
    :sunday
  ]

  @doc """
  Shifts date by `:days`, `:weeks`, `:months` and `:years`

  # Example

      iex> RecurringEvents.Date.shift_date(~D[2011-02-04], 4, :days)
      ~D[2011-02-08]

      iex> RecurringEvents.Date.shift_date(~D[2011-02-04], 2, :years)
      ~D[2013-02-04]

  """
  def shift_date(%{year: year, month: month, day: day} = date, count, period) do
    {new_year, new_month, new_day} = shift_date({year, month, day}, count, period)
    %{date | year: new_year, month: new_month, day: new_day}
  end

  def shift_date({_year, _month, _day} = date, count, :days) do
    date
    |> :calendar.date_to_gregorian_days()
    |> Kernel.+(count)
    |> :calendar.gregorian_days_to_date()
  end

  def shift_date({_year, _month, _day} = date, count, :weeks) do
    shift_date(date, count * 7, :days)
  end

  def shift_date({year, month, day}, count, :months) do
    months = year * 12 + (month - 1) + count

    new_year = div(months, 12)
    new_month = rem(months, 12) + 1

    last_day = :calendar.last_day_of_the_month(new_year, new_month)
    new_day = min(day, last_day)

    {new_year, new_month, new_day}
  end

  def shift_date({year, month, day}, count, :years) do
    {year + count, month, day}
  end

  @doc """
  Returns last daty of the month for provided date.

  # Example

      iex> RecurringEvents.Date.last_day_of_the_month(~D[2017-02-04])
      28

  """
  def last_day_of_the_month(%{year: year, month: month}) do
    :calendar.last_day_of_the_month(year, month)
  end

  def last_day_of_the_month({year, month, _day}) do
    :calendar.last_day_of_the_month(year, month)
  end

  @doc """
  Returns week day of provided date

  # Example

      iex> RecurringEvents.Date.week_day(~D[2017-02-04])
      :saturday

  """
  def week_day(%{year: year, month: month, day: day}) do
    week_day({year, month, day})
  end

  def week_day({_year, _month, _day} = date) do
    @week_days |> Enum.at(:calendar.day_of_the_week(date) - 1)
  end

  @doc """
  Returns numbered week day of provided date

  # Example

     iex> RecurringEvents.Date.numbered_week_day(~D[2017-02-04], :month)
     {1, :saturday}

     iex> RecurringEvents.Date.numbered_week_day(~D[2017-02-04], :year, :backward)
     {-48, :saturday}

  """
  def numbered_week_day(date, period \\ :month, order \\ :foreward)

  def numbered_week_day(%{year: year, month: month, day: day}, period, order) do
    numbered_week_day({year, month, day}, period, order)
  end

  def numbered_week_day({_year, _month, day} = date, :month, :foreward) do
    day_of_the_week = week_day(date)
    count = div(day - 1, 7) + 1
    {count, day_of_the_week}
  end

  def numbered_week_day({_year, _month, day} = date, :month, :backward) do
    day_of_the_week = week_day(date)
    last_day = last_day_of_the_month(date)
    count = div(last_day - day, 7) + 1
    {-count, day_of_the_week}
  end

  def numbered_week_day({_year, _month, _day} = date, :year, :foreward) do
    day_of_the_week = week_day(date)
    count = div(day_of_the_year(date) - 1, 7) + 1
    {count, day_of_the_week}
  end

  def numbered_week_day({year, _month, _day} = date, :year, :backward) do
    day_of_the_week = week_day(date)
    last_day = if(:calendar.is_leap_year(year), do: 366, else: 365)
    count = div(last_day - day_of_the_year(date), 7) + 1
    {-count, day_of_the_week}
  end

  @doc """
  Returns year day of provided date

  # Example

     iex> RecurringEvents.Date.day_of_the_year(~D[2017-02-04])
     35


  """
  def day_of_the_year(%{year: year, month: month, day: day}) do
    day_of_the_year({year, month, day})
  end

  def day_of_the_year({year, _month, _day} = date) do
    {days, _} = :calendar.time_difference({{year, 1, 1}, @time}, {date, @time})
    days + 1
  end

  @doc """
  Shifts week days

  # Example

      iex> RecurringEvents.Date.shift_week_day(:monday, -3)
      :friday

  """
  def shift_week_day(day, shift) do
    day_no =
      @week_days
      |> Enum.find_index(fn d -> d == day end)
      |> Kernel.+(shift)
      |> rem(7)

    Enum.at(@week_days, day_no)
  end

  @doc """
  Returns next day of the week

  # Example

      iex> RecurringEvents.Date.next_week_day(:friday)
      :saturday

  """
  def next_week_day(day) do
    shift_week_day(day, 1)
  end

  @doc """
  Returns previous day of the week

  # Example

      iex> RecurringEvents.Date.prev_week_day(:wednesday)
      :tuesday

  """
  def prev_week_day(day) do
    shift_week_day(day, -1)
  end

  @doc """
  Compares two dates, time if provided will be ignored.

  # Example

      iex> RecurringEvents.Date.compare(~D[2017-02-05], ~D[2017-02-01])
      :gt

      iex> RecurringEvents.Date.compare(~D[2017-02-01], ~D[2017-02-05])
      :lt

      iex> RecurringEvents.Date.compare(~N[2017-02-05 12:00:00],
      ...>                              ~N[2017-02-05 18:21:11])
      :eq

  """
  def compare(%{year: y1, month: m1, day: d1}, %{year: y2, month: m2, day: d2}) do
    compare({y1, m1, d1}, {y2, m2, d2})
  end

  def compare({y1, m1, d1}, {y2, m2, d2}) do
    cond do
      y1 == y2 and m1 == m2 and d1 == d2 ->
        :eq

      y1 > y2 or (y1 == y2 and m1 > m2) or (y1 == y2 and m1 == m2 and d1 > d2) ->
        :gt

      true ->
        :lt
    end
  end
end
