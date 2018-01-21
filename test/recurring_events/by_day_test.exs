defmodule RecurringEvents.ByDayTest do
  use ExUnit.Case
  doctest RecurringEvents.ByDay

  alias RecurringEvents.ByDay

  @wednesday ~D[2017-01-25]
  @monday ~D[2017-01-23]

  test "can be filtered by day of the week when freq: :daily" do
    assert [@monday] ==
             @monday
             |> ByDay.unfold(%{freq: :daily, by_day: :monday})
             |> Enum.to_list()
  end

  test "can be inflate by week when freq: :weekly" do
    assert [@monday, @wednesday] ==
             @monday
             |> ByDay.unfold(%{freq: :weekly, by_day: [:monday, :wednesday]})
             |> Enum.to_list()
  end

  test "will not change if filtered by provided day with freq: weekly" do
    assert [@wednesday] ==
             @wednesday
             |> ByDay.unfold(%{freq: :weekly, by_day: :wednesday})
             |> Enum.to_list()
  end

  test "can be inflate by numbered day of the week when freq: :monthly" do
    assert [~D[2017-01-09]] ==
             @wednesday
             |> ByDay.unfold(%{freq: :monthly, by_day: {2, :monday}})
             |> Enum.to_list()
  end

  test "can be inflate by month when freq: :monthly" do
    assert [~D[2017-01-04], ~D[2017-01-11], ~D[2017-01-18], @wednesday] ==
             @wednesday
             |> ByDay.unfold(%{freq: :monthly, by_day: :wednesday})
             |> Enum.to_list()
  end

  test "can be inflate by year when freq: yearly" do
    assert [
             ~D[2017-01-06],
             ~D[2017-01-13],
             ~D[2017-01-20],
             ~D[2017-01-27],
             ~D[2017-02-03],
             ~D[2017-02-10],
             ~D[2017-02-17],
             ~D[2017-02-24],
             ~D[2017-03-03],
             ~D[2017-03-10],
             ~D[2017-03-17],
             ~D[2017-03-24],
             ~D[2017-03-31]
           ] ==
             @wednesday
             |> ByDay.unfold(%{freq: :yearly, by_day: :friday})
             |> Enum.take(13)
  end

  test "can be inflate by month when by_month: is present" do
    assert [~D[2017-01-04], ~D[2017-01-11], ~D[2017-01-18], @wednesday] ==
             @wednesday
             |> ByDay.unfold(%{freq: :daily, by_day: :wednesday, by_month: []})
             |> Enum.to_list()

    assert [~D[2017-01-04], ~D[2017-01-11], ~D[2017-01-18], @wednesday] ==
             @wednesday
             |> ByDay.unfold(%{freq: :weekly, by_day: :wednesday, by_month: 2})
             |> Enum.to_list()

    assert [~D[2017-01-04], ~D[2017-01-11], ~D[2017-01-18], @wednesday] ==
             @wednesday
             |> ByDay.unfold(%{freq: :yearly, by_day: :wednesday, by_month: nil})
             |> Enum.to_list()
  end

  test "should filter when by_month_day: present" do
    assert [@monday] ==
             @monday
             |> ByDay.unfold(%{by_day: [:monday, :tuesday], freq: :monthly, by_month_day: []})
             |> Enum.to_list()

    assert [] ==
             @wednesday
             |> ByDay.unfold(%{by_day: :saturday, freq: :weekly, by_month_day: nil})
             |> Enum.to_list()
  end
end
