defmodule RecurringEvents.ByMonthDayTest do
  use ExUnit.Case
  doctest RecurringEvents.ByMonthDay

  alias RecurringEvents.ByMonthDay

  @wednesday ~D[2017-01-25]
  @monday ~D[2017-01-23]

  test "can be filtered by day of the month when freq: :daily" do
    assert [] ==
             @monday
             |> ByMonthDay.unfold(%{freq: :daily, by_month_day: 20})
             |> Enum.to_list()

    assert [@monday] ==
             @monday
             |> ByMonthDay.unfold(%{freq: :daily, by_month_day: 23})
             |> Enum.to_list()
  end

  test "can be filtered by day of the month when freq: :daily and negative day" do
    assert [@wednesday] ==
             @wednesday
             |> ByMonthDay.unfold(%{freq: :daily, by_month_day: -7})
             |> Enum.to_list()
  end

  test "can be inflate by month day when freq: :weekly" do
    assert [@monday, @wednesday] ==
             @monday
             |> ByMonthDay.unfold(%{freq: :weekly, by_month_day: [23, -7]})
             |> Enum.to_list()
  end

  test "will not change if filtered by provided month day with freq: weekly" do
    assert [@wednesday] ==
             @wednesday
             |> ByMonthDay.unfold(%{freq: :weekly, by_month_day: 25})
             |> Enum.to_list()
  end

  test "can be inflated by month when freq: :monthly" do
    assert [~D[2017-01-01], ~D[2017-01-15], ~D[2017-01-31]] ==
             @wednesday
             |> ByMonthDay.unfold(%{freq: :monthly, by_month_day: [1, 15, -1]})
             |> Enum.to_list()
  end

  test "can be filtered when by_day: present" do
    assert [] ==
             @wednesday
             |> ByMonthDay.unfold(%{by_day: [], freq: :monthly, by_month_day: [1, 15, -1]})
             |> Enum.to_list()

    assert [@wednesday] ==
             @wednesday
             |> ByMonthDay.unfold(%{by_day: nil, freq: :monthly, by_month_day: 25})
             |> Enum.to_list()
  end

  test "can be inflate by year when freq: yearly" do
    assert [
             ~D[2017-01-01],
             ~D[2017-01-31],
             ~D[2017-02-01],
             ~D[2017-02-28],
             ~D[2017-03-01],
             ~D[2017-03-31],
             ~D[2017-04-01],
             ~D[2017-04-30],
             ~D[2017-05-01],
             ~D[2017-05-31],
             ~D[2017-06-01],
             ~D[2017-06-30]
           ] ==
             @wednesday
             |> ByMonthDay.unfold(%{freq: :yearly, by_month_day: [1, -1]})
             |> Enum.take(12)
  end

  test "can be inflate by month when by_month: is present" do
    assert [~D[2017-01-15]] ==
             @wednesday
             |> ByMonthDay.unfold(%{freq: :daily, by_month_day: 15, by_month: []})
             |> Enum.to_list()

    assert [~D[2017-01-30]] ==
             @wednesday
             |> ByMonthDay.unfold(%{freq: :weekly, by_month_day: 30, by_month: 2})
             |> Enum.to_list()

    assert [~D[2017-01-01], ~D[2017-01-02], ~D[2017-01-03]] ==
             @wednesday
             |> ByMonthDay.unfold(%{freq: :yearly, by_month_day: [1, 2, 3], by_month: nil})
             |> Enum.to_list()
  end
end
