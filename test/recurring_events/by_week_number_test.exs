defmodule RecurringEvents.ByWeekNumberTest do
  use ExUnit.Case
  doctest RecurringEvents.ByWeekNumber

  alias RecurringEvents.ByWeekNumber

  @date ~D[2017-01-20]

  # %{by_week_number: _days, by_month: _} -> filter(date, rules)
  # %{by_week_number: _days, freq: :yearly} -> year_inflate(date, rules)

  test "should filter when freq: :daily" do
    assert [@date] == ByWeekNumber.unfold(@date, %{freq: :daily, by_week_number: 3})
    assert [] == ByWeekNumber.unfold(@date, %{freq: :daily, by_week_number: [2, 4]})
    assert [@date] == ByWeekNumber.unfold(@date, %{freq: :daily, by_week_number: [2, 3, -49]})
  end

  test "should filter when freq: :weekly" do
    assert [@date] == ByWeekNumber.unfold(@date, %{freq: :weekly, by_week_number: 3})
    assert [] == ByWeekNumber.unfold(@date, %{freq: :weekly, by_week_number: [-51, 4]})
    assert [@date] == ByWeekNumber.unfold(@date, %{freq: :weekly, by_week_number: [3]})
  end

  test "should inflate when freq: :monthly" do
    assert [
             ~D[2017-01-16],
             ~D[2017-01-17],
             ~D[2017-01-18],
             ~D[2017-01-19],
             ~D[2017-01-20],
             ~D[2017-01-21],
             ~D[2017-01-22]
           ] ==
             ByWeekNumber.unfold(@date, %{freq: :monthly, by_week_number: 3})
             |> Enum.take(999)

    assert [
             ~D[2017-01-09],
             ~D[2017-01-10],
             ~D[2017-01-11],
             ~D[2017-01-12],
             ~D[2017-01-13],
             ~D[2017-01-14],
             ~D[2017-01-15],
             ~D[2017-01-23],
             ~D[2017-01-24],
             ~D[2017-01-25],
             ~D[2017-01-26],
             ~D[2017-01-27],
             ~D[2017-01-28],
             ~D[2017-01-29]
           ] ==
             ByWeekNumber.unfold(@date, %{freq: :monthly, by_week_number: [2, 4]})
             |> Enum.take(999)
  end

  test "should inflate when freq: :yearly" do
    assert [
             ~D[2017-01-19],
             ~D[2017-01-20],
             ~D[2017-01-21],
             ~D[2017-01-22],
             ~D[2017-01-23],
             ~D[2017-01-24],
             ~D[2017-01-25]
           ] ==
             ByWeekNumber.unfold(@date, %{
               freq: :monthly,
               by_week_number: -50,
               week_start: :thursday
             })
             |> Enum.take(999)
  end
end
