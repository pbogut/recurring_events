defmodule RecurringEvents.MonthlyTest do
  use ExUnit.Case
  doctest RecurringEvents

  alias RecurringEvents.Monthly

  @date ~N[2017-01-01 10:00:00]
  @range {~N[2017-01-01 00:00:00], ~N[2018-06-30 23:59:59]}
  @valid_rrule %{freq: :monthly}

  test "for count 1 should return only one event" do
    assert {:ok, [@date]} ==
      Monthly.unfold(@date, @valid_rrule |> Map.put(:count, 1), @range)
  end

  test "for until ~N[2017-02-01 00:00:00] it should return 2 events" do
    until = ~N[2017-02-01 00:00:00]
    {:ok, events} = Monthly.unfold(@date, @valid_rrule |> Map.put(:until, until), @range)
    assert 2 == Enum.count(events)
    assert [@date, %{@date | month: 2}] == events
  end

  test "with no count, until and interval it should return 18 events (1 for each month)" do
    {:ok, events} = Monthly.unfold(@date, @valid_rrule, @range)
    assert 18 == Enum.count(events)
  end

  test "for count 5 it should return 5 events" do
    {:ok, events} = Monthly.unfold(@date, @valid_rrule |> Map.put(:count, 5), @range)
    assert 5 == Enum.count(events)
  end

  test "for interval 5 it should return 4 events" do
    {:ok, events} = Monthly.unfold(@date, @valid_rrule |> Map.put(:interval, 5), @range)
    assert Enum.count(events) == 4
    assert [@date, %{@date | month: 6}, %{@date | month: 11},
                   %{@date | year: 2018, month: 4}] == events
  end
end
