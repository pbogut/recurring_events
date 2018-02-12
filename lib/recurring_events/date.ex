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
  def shift_date(date, count, period)
      when period == :hours or period == :minutes or period == :seconds do
    {
      {new_year, new_month, new_day},
      {new_hour, new_minute, new_second}
    } = shift_time(date, count, period)

    %{
      date
      | year: new_year,
        month: new_month,
        day: new_day,
        hour: new_hour,
        minute: new_minute,
        second: new_second
    }
  end

  def shift_date(%{year: year, month: month, day: day} = date, count, period) do
    {new_year, new_month, new_day} = shift_date({year, month, day}, count, period)
    %{date | year: new_year, month: new_month, day: new_day}
  end

  def shift_date(date, 0, _), do: date

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
    new_year = year + count
    last_day = :calendar.last_day_of_the_month(new_year, month)
    new_day = min(day, last_day)

    {new_year, month, new_day}
  end

  # defp shift_time(%{hour: hour, minute: minute, second: second} = date, count, period) do
  # {new_hour, new_minute, new_second} = shift_date({hour, minute, second}, count, period)
  # %{date | hour: new_hour, minute: new_minute, second: new_second}
  # end

  defp shift_time(
         %{year: _, month: _, day: _, hour: _, minute: _, second: _} = date,
         count,
         period
       ) do
    shift_time(to_erl_datetime(date), count, period)
  end

  defp shift_time(datetime, 0, _), do: datetime

  defp shift_time({date, {hour, minute, second}}, count, :hours) do
    days = div(hour + count, 24)
    new_hour = rem(hour + count, 24)

    {shift_date(date, days, :days), {new_hour, minute, second}}
  end

  defp shift_time({date, {_, minute, second} = time}, count, :minutes) do
    hours = div(minute + count, 60)
    new_minute = rem(minute + count, 60)
    {new_date, {new_hour, _, _}} = shift_time({date, time}, hours, :hours)
    {new_date, {new_hour, new_minute, second}}
  end

  defp shift_time({date, {_, _, second} = time}, count, :seconds) do
    minutes = div(second + count, 60)
    new_second = rem(second + count, 60)
    {new_date, {new_hour, new_minute, _}} = shift_time({date, time}, minutes, :minutes)
    {new_date, {new_hour, new_minute, new_second}}
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
  Returns week number of provided date
  Minimum 4 days of week are required in the first week, `:week_start`
  can be provided

  # Example

     iex> RecurringEvents.Date.week_number(~D[2017-01-05])
     1
     iex> RecurringEvents.Date.week_number(~D[2017-01-05], reversed: true)
     -52


  """

  def week_number(date, options \\ [])

  def week_number(%{year: year, month: month, day: day}, options) do
    week_number({year, month, day}, options)
  end

  def week_number({year, _month, _day} = date, reversed: false, week_start: week_start) do
    year_start_day = week_day({year, 1, 1})
    diff = week_day_diff(year_start_day, week_start)
    shift_week = if(diff < 4, do: -1, else: 0)

    max_weeks = weeks_count(year, week_start)
    week_number = div(day_of_the_year(date) - 1 - diff + 7, 7) + 1 + shift_week

    cond do
      week_number == 0 -> weeks_count(year - 1, week_start)
      max_weeks < week_number -> week_number - max_weeks
      true -> week_number
    end
  end

  def week_number({year, month, _day} = date, reversed: true, week_start: week_start) do
    number = week_number(date, reversed: false, week_start: week_start)

    cond do
      month == 1 and number > 25 -> number - 1 - weeks_count(year - 1, week_start)
      month == 12 and number < 25 -> number - 1 - weeks_count(year + 1, week_start)
      true -> number - 1 - weeks_count(year, week_start)
    end
  end

  def week_number(date, options) do
    reversed = Keyword.get(options, :reversed, false)
    week_start = Keyword.get(options, :week_start, :monday)
    week_number(date, reversed: reversed, week_start: week_start)
  end

  defp weeks_count(year, week_start) do
    year_start_day = week_day({year, 1, 1})
    diff = week_day_diff(year_start_day, week_start)
    has_53 = diff == 4 or (diff == 5 and :calendar.is_leap_year(year))

    if(has_53, do: 53, else: 52)
  end

  defp week_day_diff(day1, day2) when is_atom(day1) and is_atom(day2) do
    week_day_diff(
      Enum.find_index(@week_days, &(day1 == &1)),
      Enum.find_index(@week_days, &(day2 == &1))
    )
  end

  defp week_day_diff(day1_no, day2_no) when day1_no < day2_no do
    day2_no - day1_no
  end

  defp week_day_diff(day1_no, day2_no) when day1_no > day2_no do
    day2_no - day1_no + 7
  end

  defp week_day_diff(day1_no, day2_no) when day1_no == day2_no, do: 0

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
  Compares two dates or datetimes (it ignores tz)

  # Example

      iex> RecurringEvents.Date.compare(~D[2017-02-05], ~D[2017-02-01])
      :gt

      iex> RecurringEvents.Date.compare(~D[2017-02-01], ~D[2017-02-05])
      :lt

      iex> RecurringEvents.Date.compare(~D[2017-02-05], ~D[2017-02-05])
      :eq

      iex> RecurringEvents.Date.compare(~N[2017-02-05 12:00:00],
      ...>                              ~N[2017-02-05 18:21:11])
      :lt

  """

  def compare(
        %{
          year: y1,
          month: m1,
          day: d1,
          hour: h1,
          minute: i1,
          second: s1
        },
        %{
          year: y2,
          month: m2,
          day: d2,
          hour: h2,
          minute: i2,
          second: s2
        }
      ) do
    case compare({y1, m1, d1}, {y2, m2, d2}) do
      :eq -> compare({h1, i1, s1}, {h2, i2, s2})
      ltgt -> ltgt
    end
  end

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

  defp to_erl_datetime(date) do
    {to_erl_date(date), to_erl_time(date)}
  end

  defp to_erl_date(%{year: year, month: month, day: day}) do
    {year, month, day}
  end

  defp to_erl_time(%{hour: hour, minute: minute, second: second}) do
    {hour, minute, second}
  end
end
