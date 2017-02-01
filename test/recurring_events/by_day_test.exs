defmodule RecurringEvents.ByDayTest do
  use ExUnit.Case
  doctest RecurringEvents.ByDay

  alias RecurringEvents.ByDay

  @wednesday ~D[2017-01-25]
  @monday ~D[2017-01-23]

  test "can be filetered by day of the week when freq: :daily" do
    assert [@monday] ==
      ByDay.unfold(@monday, %{freq: :daily, by_day: :monday}, {})
  end

  test "can be inflate by week when freq: :weekly" do
    assert [@monday, @wednesday] ==
      ByDay.unfold(@monday, %{freq: :weekly, by_day: [:monday, :wednesday]}, {})
  end

  test "will not change if filtered by provided day with freq: weekly" do
    assert [@wednesday] ==
      ByDay.unfold(@wednesday, %{freq: :weekly, by_day: :wednesday}, {})
  end

  test "can be inflate by month when freq: :monthly" do
    assert [~D[2017-01-04], ~D[2017-01-11], ~D[2017-01-18], @wednesday] ==
      ByDay.unfold(@wednesday, %{freq: :monthly, by_day: :wednesday}, {})
  end

  test "can be inflate by year when freq: yearly" do
    assert [
      ~D[2017-01-06], ~D[2017-01-13], ~D[2017-01-20], ~D[2017-01-27],
      ~D[2017-02-03], ~D[2017-02-10], ~D[2017-02-17], ~D[2017-02-24],
      ~D[2017-03-03], ~D[2017-03-10], ~D[2017-03-17], ~D[2017-03-24],
      ~D[2017-03-31],
    ] ==
      @wednesday
      |> ByDay.unfold(%{freq: :yearly, by_day: :friday}, {})
      |> Enum.take(13)
  end

  test "can be inflate by month when by_month: is present" do
    assert [~D[2017-01-04], ~D[2017-01-11], ~D[2017-01-18], @wednesday] ==
      ByDay.unfold(@wednesday, %{freq: :daily, by_day: :wednesday, by_month: []}, {})
    assert [~D[2017-01-04], ~D[2017-01-11], ~D[2017-01-18], @wednesday] ==
      ByDay.unfold(@wednesday, %{freq: :weekly, by_day: :wednesday, by_month: 2}, {})
    assert [~D[2017-01-04], ~D[2017-01-11], ~D[2017-01-18], @wednesday] ==
      ByDay.unfold(@wednesday, %{freq: :yearly, by_day: :wednesday, by_month: nil}, {})
  end
end
