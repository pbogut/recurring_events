defmodule RecurringEvents.DateTest do
  use ExUnit.Case
  doctest RecurringEvents.Date

  alias RecurringEvents.Date

  @date ~N[2017-01-30 10:00:00]

  test "can shift date by N days" do
    assert ~N[2017-01-31 10:00:00] == Date.shift_date(@date, 1, :days)
    assert ~N[2017-02-01 10:00:00] == Date.shift_date(@date, 2, :days)
    assert ~N[2018-01-30 10:00:00] == Date.shift_date(@date, 365, :days)
  end

  test "can shift date by N weeks" do
    assert ~N[2017-02-06 10:00:00] == Date.shift_date(@date, 1, :weeks)
    assert ~N[2017-02-13 10:00:00] == Date.shift_date(@date, 2, :weeks)
    assert ~N[2017-02-20 10:00:00] == Date.shift_date(@date, 3, :weeks)
  end

  test "can shift date by N months" do
    assert ~N[2017-02-28 10:00:00] == Date.shift_date(@date, 1, :months)
    assert ~N[2017-03-30 10:00:00] == Date.shift_date(@date, 2, :months)
    assert ~N[2017-06-30 10:00:00] == Date.shift_date(@date, 5, :months)
    assert ~N[2018-04-30 10:00:00] == Date.shift_date(@date, 15, :months)
  end

  test "can shift date by -N months" do
    assert ~N[2016-12-30 10:00:00] == Date.shift_date(@date, -1, :months)
    assert ~N[2016-11-30 10:00:00] == Date.shift_date(@date, -2, :months)
    assert ~N[2016-08-30 10:00:00] == Date.shift_date(@date, -5, :months)
    assert ~N[2015-10-30 10:00:00] == Date.shift_date(@date, -15, :months)
  end

  test "can shift date by N years" do
    assert %{@date | year: 2018} == Date.shift_date(@date, 1, :years)
    assert %{@date | year: 2019} == Date.shift_date(@date, 2, :years)
    assert %{@date | year: 2012} == Date.shift_date(@date, -5, :years)
    assert %{@date | year: 2032} == Date.shift_date(@date, 15, :years)

    date = ~D[1996-02-29]
    assert %{date | year: 1997, day: 28} == Date.shift_date(date, 1, :years)
    assert %{date | year: 2000, day: 29} == Date.shift_date(date, 4, :years)
  end

  test "can return day of the week" do
    assert :monday == Date.week_day(~D[2017-01-16])
    assert :tuesday == Date.week_day(~D[2017-01-17])
    assert :wednesday == Date.week_day(~D[2017-01-18])
    assert :thursday == Date.week_day({2017, 01, 19})
    assert :friday == Date.week_day(~D[2017-01-20])
    assert :saturday == Date.week_day(~D[2017-01-21])
    assert :sunday == Date.week_day({2017, 01, 22})
  end

  test "can return numbered day of the week" do
    assert {3, :monday} == Date.numbered_week_day(~D[2017-01-16], :month)
    assert {6, :thursday} == Date.numbered_week_day({2017, 2, 9}, :year)
    assert {-2, :wednesday} == Date.numbered_week_day(~D[2017-01-18], :month, :backward)
    assert {-10, :friday} == Date.numbered_week_day(~D[2017-10-27], :year, :backward)
    assert {-2, :friday} == Date.numbered_week_day(~D[2017-01-20], :month, :backward)
    assert {-1, :friday} == Date.numbered_week_day(~D[2017-01-27], :month, :backward)
    assert {9, :saturday} == Date.numbered_week_day(~D[2017-03-04], :year, :foreward)
    assert {4, :sunday} == Date.numbered_week_day({2017, 01, 22})
  end

  test "can compare two dates" do
    assert :eq == Date.compare(@date, @date)
    assert :gt == Date.compare({2018, 02, 01}, {2018, 01, 31})
    assert :lt == Date.compare({2018, 01, 01}, {2018, 01, 31})
  end

  test "can compare two date times" do
    assert :eq == Date.compare(@date, @date)
    assert :gt == Date.compare(~N[2017-01-30 10:10:00], ~N[2017-01-30 10:00:00])
    assert :lt == Date.compare(~N[2017-01-30 15:00:00], ~N[2017-01-30 15:00:01])
  end

  test "can return last day of the month" do
    assert 29 == Date.last_day_of_the_month(~D[2020-02-01])
    assert 31 == Date.last_day_of_the_month(~D[2018-08-21])
    assert 28 == Date.last_day_of_the_month(~D[2018-02-11])
  end

  test "can return next week day" do
    assert :friday == Date.next_week_day(:thursday)
    assert :monday == Date.next_week_day(:sunday)
    assert :sunday == Date.next_week_day(:saturday)
  end

  test "can return previous day week day" do
    assert :thursday == Date.prev_week_day(:friday)
    assert :sunday == Date.prev_week_day(:monday)
    assert :monday == Date.prev_week_day(:tuesday)
  end

  test "can return day of the year" do
    assert 1 == Date.day_of_the_year(~D[2017-01-01])
    assert 100 == Date.day_of_the_year(~D[2017-04-10])
    assert 300 == Date.day_of_the_year(~D[2017-10-27])
    assert 365 == Date.day_of_the_year(~D[2017-12-31])
  end

  test "can return year week number for the daty" do
    assert 1 = Date.week_number({1997, 1, 5})
    assert 2 = Date.week_number({1997, 1, 6})
    assert 1 = Date.week_number({1999, 1, 10})
    assert 2 = Date.week_number({1999, 1, 11})
    assert 53 = Date.week_number({1987, 12, 28})
    assert 1 = Date.week_number({1985, 12, 30})

    assert 2 = Date.week_number({1997, 1, 5}, week_start: :sunday)
    assert 1 = Date.week_number({1997, 1, 6}, week_start: :tuesday)
    assert 2 = Date.week_number({2000, 1, 10}, week_start: :friday)
    assert 53 = Date.week_number({2000, 1, 3}, week_start: :tuesday)

    assert 2 = Date.week_number({1999, 1, 11})
    assert 1 = Date.week_number({1999, 1, 6})
    assert 20 = Date.week_number({1997, 5, 12})
    assert 21 = Date.week_number({1997, 5, 20})
    assert 53 = Date.week_number({1998, 12, 28})
  end

  test "can return negative year week number for the daty" do
    assert -1 = Date.week_number({1997, 12, 22}, reversed: true)
    assert -2 = Date.week_number({1997, 12, 21}, reversed: true)
    assert -50 = Date.week_number({1997, 1, 13}, reversed: true)
    assert -51 = Date.week_number({1997, 1, 12}, reversed: true)
    assert -51 = Date.week_number({1997, 1, 12}, reversed: true, something: 1)
    assert -53 = Date.week_number({1987, 1, 1}, reversed: true)
    assert -52 = Date.week_number({1985, 12, 30}, reversed: true)

    assert -53 = Date.week_number({1997, 1, 1}, week_start: :sunday, reversed: true)
    assert -52 = Date.week_number({1997, 1, 5}, week_start: :sunday, reversed: true)
    assert -52 = Date.week_number({1997, 1, 6}, week_start: :tuesday, reversed: true)
    assert -51 = Date.week_number({2000, 1, 10}, week_start: :friday, reversed: true)
    assert -1 = Date.week_number({2000, 1, 3}, week_start: :tuesday, reversed: true)

    assert -33 = Date.week_number({1997, 5, 12}, reversed: true)
    assert -32 = Date.week_number({1997, 5, 20}, reversed: true)
    assert -1 = Date.week_number({1998, 12, 28}, reversed: true)
  end
end
