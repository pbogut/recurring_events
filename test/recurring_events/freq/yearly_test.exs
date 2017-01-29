defmodule RecurringEvents.Freq.YearlyTest do
  use ExUnit.Case
  doctest RecurringEvents.Freq.Yearly

  alias RecurringEvents.Freq.Yearly

  @date ~N[2017-01-01 10:00:00]
  @valid_rrule %{freq: :yearly}

  test "for count 1 should return only one event" do
    events = Yearly.unfold!(@date, @valid_rrule |> Map.put(:count, 1))
    assert [@date] == events |> Enum.take(999)
  end

  test "for until ~N[2018-11-01 00:00:00] it should return 2 events" do
    until = ~N[2018-11-01 00:00:00]
    events = Yearly.unfold!(@date, @valid_rrule |> Map.put(:until, until))
    assert 2 == Enum.count(events)
    assert [@date, %{@date | year: 2018}] == events |> Enum.take(999)
  end

  test "with no count, until and interval it should steam forever" do
    events = Yearly.unfold!(@date, @valid_rrule)
    assert 1 == Enum.count(events |> Enum.take(1))
    assert 16 == Enum.count(events |> Enum.take(16))
    assert 96 == Enum.count(events |> Enum.take(96))
  end

  test "for count 5 it should return 5 events" do
    {:ok, events} = Yearly.unfold(@date, @valid_rrule |> Map.put(:count, 5))
    assert 5 == Enum.count(events)
  end

  test "for interval 5 it should return event every 5th year" do
    events = Yearly.unfold!(@date, @valid_rrule |> Map.put(:interval, 5))
    assert 2 == Enum.count(events |> Enum.take(2))
    assert [@date, %{@date | year: 2022}] == events |> Enum.take(2)
  end
end
