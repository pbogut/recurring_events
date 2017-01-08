defmodule RecurringEvents.YearlyTest do
  use ExUnit.Case
  doctest RecurringEvents

  alias RecurringEvents.Yearly

  @date ~N[2017-01-01 10:00:00]
  @range {~N[2017-01-01 00:00:00], ~N[2026-12-31 23:59:59]}
  @valid_rrule %{freq: :yearly}

  test "for count 1 should return only one event" do
    assert {:ok, [@date]} ==
      Yearly.unfold(@date, @valid_rrule |> Map.put(:count, 1), @range)
  end

  test "for until ~N[2018-11-01 00:00:00] it should return 2 events" do
    until = ~N[2018-11-01 00:00:00]
    {:ok, events} = Yearly.unfold(@date, @valid_rrule |> Map.put(:until, until), @range)
    assert Enum.count(events) == 2
    assert [@date, %{@date | year: 2018}] == events
  end

  test "with no count, until and interval it should return 10 events (1 for each year)" do
    {:ok, events} = Yearly.unfold(@date, @valid_rrule, @range)
    assert Enum.count(events) == 10
  end

  test "for count 5 it should return 5 events" do
    {:ok, events} = Yearly.unfold(@date, @valid_rrule |> Map.put(:count, 5), @range)
    assert Enum.count(events) == 5
  end

  test "for interval 5 it should return 2 events" do
    {:ok, events} = Yearly.unfold(@date, @valid_rrule |> Map.put(:interval, 5), @range)
    assert Enum.count(events) == 2
    assert [@date, %{@date | year: 2022}] == events
  end
end
