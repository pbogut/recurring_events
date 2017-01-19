defmodule RecurringEvents.Freq.DailyTest do
  use ExUnit.Case
  doctest RecurringEvents.Freq.Daily

  alias RecurringEvents.Freq.Daily

  @date ~N[2017-12-28 10:00:00]
  @range {~N[2017-12-28 00:00:00], ~N[2018-02-01 23:59:59]}
  @valid_rrule %{freq: :daily}

  test "for count 1 should return only one event" do
    assert {:ok, [@date]} ==
      Daily.unfold(@date, @valid_rrule |> Map.put(:count, 1), @range)
  end

  test "for until ~N[2017-12-29 00:00:00] it should return 2 events" do
    until = ~N[2017-12-29 00:00:00]
    {:ok, events} = Daily.unfold(@date, @valid_rrule |> Map.put(:until, until), @range)
    assert 2 == Enum.count(events)
    assert [@date, %{@date | day: 29}] == events
  end

  test "with no count, until and interval it should return 35 events (1 for each day)" do
    {:ok, events} = Daily.unfold(@date, @valid_rrule, @range)
    assert 36 == Enum.count(events)
  end

  test "for count 5 it should return 5 events" do
    {:ok, events} = Daily.unfold(@date, @valid_rrule |> Map.put(:count, 5), @range)
    assert 5 == Enum.count(events)
  end

  test "for interval 5 it should return 4 events" do
    {:ok, events} = Daily.unfold(@date, @valid_rrule |> Map.put(:interval, 5), @range)
    assert 8 == Enum.count(events)
  end
end
