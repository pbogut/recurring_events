defmodule RecurringEvents.WeeklyTest do
  use ExUnit.Case
  doctest RecurringEvents

  alias RecurringEvents.Weekly

  @date ~N[2017-12-28 10:00:00]
  @range {~N[2017-12-28 00:00:00], ~N[2018-02-01 23:59:59]}
  @valid_rrule %{freq: :weekly}

  test "for count 1 should return only one event" do
    assert {:ok, [@date]} ==
      Weekly.unfold(@date, @valid_rrule |> Map.put(:count, 1), @range)
  end

  test "for until ~N[2018-01-11 00:00:00] it should return 3 events" do
    until = ~N[2018-01-11 00:00:00]
    {:ok, events} = Weekly.unfold(@date, @valid_rrule |> Map.put(:until, until), @range)
    assert 3 == Enum.count(events)
    assert [@date, ~N[2018-01-04 10:00:00], ~N[2018-01-11 10:00:00]] == events
  end

  test "with no count, until and interval it should return 6 events (1 for each week)" do
    {:ok, events} = Weekly.unfold(@date, @valid_rrule, @range)
    assert 6 == Enum.count(events)
  end

  test "for count 5 it should return 5 events" do
    {:ok, events} = Weekly.unfold(@date, @valid_rrule |> Map.put(:count, 5), @range)
    assert 5 == Enum.count(events)
  end

  test "for interval 5 it should return 2 events" do
    {:ok, events} = Weekly.unfold(@date, @valid_rrule |> Map.put(:interval, 5), @range)
    assert 2 == Enum.count(events)
  end
end
