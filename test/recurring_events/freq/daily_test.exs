defmodule RecurringEvents.Freq.DailyTest do
  use ExUnit.Case
  doctest RecurringEvents.Freq.Daily

  alias RecurringEvents.Freq.Daily

  @date ~D[2017-12-28]
  @valid_rrule %{freq: :daily}

  test "for count 1 should return only one event" do
    events = Daily.unfold!(@date, @valid_rrule |> Map.put(:count, 1))
    assert [@date] == events |> Enum.take(999)
  end

  test "for until ~D[2017-12-29] it should return 2 events" do
    until = ~D[2017-12-29]
    {:ok, events} = Daily.unfold(@date, @valid_rrule |> Map.put(:until, until))
    assert 2 == Enum.count(events)
    assert [@date, %{@date | day: 29}] == events |> Enum.take(999)
  end

  test "with no count, until and interval it should stream forever" do
    {:ok, events} = Daily.unfold(@date, @valid_rrule)
    assert 1 == Enum.count(events |> Enum.take(1))
    assert 16 == Enum.count(events |> Enum.take(16))
    assert 96 == Enum.count(events |> Enum.take(96))
  end

  test "for count 5 it should return 5 events" do
    {:ok, events} = Daily.unfold(@date, @valid_rrule |> Map.put(:count, 5))
    assert 5 == Enum.count(events)
  end

  test "for interval 5 it should return events every 5 days" do
    {:ok, events} = Daily.unfold(@date, @valid_rrule |> Map.put(:interval, 5))
    assert [~D[2017-12-28], ~D[2018-01-02], ~D[2018-01-07]] ==
      events |> Enum.take(3)
  end
end
