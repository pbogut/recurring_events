defmodule RecurringEvents.MonthlyTest do
  use ExUnit.Case
  doctest RecurringEvents.Monthly

  alias RecurringEvents.Monthly

  @date ~D[2017-01-01]
  @valid_rrule %{freq: :monthly}

  test "for count 1 should return only one event" do
    events = Monthly.unfold(@date, @valid_rrule |> Map.put(:count, 1))
    assert [@date] == events |> Enum.take(999)
  end

  test "for until ~D[2017-02-01] it should return 2 events" do
    until = ~D[2017-02-01]
    events = Monthly.unfold(@date, @valid_rrule |> Map.put(:until, until))
    assert 2 == Enum.count(events)
    assert [@date, %{@date | month: 2}] == events |> Enum.take(999)
  end

  test "with no count, until and interval it should stream events forever" do
    events = Monthly.unfold(@date, @valid_rrule)
    assert 1 == Enum.count(events |> Enum.take(1))
    assert 16 == Enum.count(events |> Enum.take(16))
    assert 96 == Enum.count(events |> Enum.take(96))
  end

  test "for count 5 it should return 5 events" do
    events = Monthly.unfold(@date, @valid_rrule |> Map.put(:count, 5))
    assert 5 == Enum.count(events)
  end

  test "for interval 5 it should return events every 5 months" do
    events = Monthly.unfold(@date, @valid_rrule |> Map.put(:interval, 5))

    assert [@date, %{@date | month: 6}, %{@date | month: 11}, %{@date | year: 2018, month: 4}] ==
             events |> Enum.take(4)
  end
end
