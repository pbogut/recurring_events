defmodule RecurringEventsTest do
  use ExUnit.Case
  doctest RecurringEvents

  @date ~N[2017-01-01 10:00:00]
  @valid_rrule %{freq: :yearly}
  @range_3y {~D[2017-01-01], ~D[2019-12-31]}
  @range_3m {~D[2017-01-01], ~D[2017-03-31]}

  test "freq is required" do
    assert {:error, _} =
      RecurringEvents.unfold(@date, %{}, @range_3y)
  end

  test "can have eathier until or count" do
    assert {:error, _} =
      RecurringEvents.unfold(@date,
                             Map.merge(@valid_rrule, %{count: 1, until: 2}),
                             @range_3y)
    assert {:ok, _} =
      RecurringEvents.unfold(@date, Map.put(@valid_rrule, :until, @date), @range_3y)
    assert {:ok, _} =
      RecurringEvents.unfold(@date, Map.put(@valid_rrule, :count, 1), @range_3y)
  end

  test "can handle yearly frequency" do
    assert {:ok, events}  =
      RecurringEvents.unfold(@date, %{freq: :yearly}, @range_3y)
    assert 3 = Enum.count(events)
  end

  test "can handle monthly frequency" do
    assert {:ok, events}  =
      RecurringEvents.unfold(@date, %{freq: :monthly}, @range_3y)
    assert 36 = Enum.count(events)
  end

  test "can handle daily frequency" do
    assert {:ok, events}  =
      RecurringEvents.unfold(@date, %{freq: :daily}, @range_3m)
    assert 90 = Enum.count(events)
  end

  test "can handle weekly frequency" do
    assert {:ok, events}  =
      RecurringEvents.unfold(@date, %{freq: :weekly}, @range_3m)
    assert 13 = Enum.count(events)
  end
end
