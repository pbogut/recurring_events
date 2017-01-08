defmodule RecurringEventsTest do
  use ExUnit.Case
  doctest RecurringEvents

  @date ~N[2017-01-01 10:00:00]
  @valid_rrule %{freq: :weekly}

  test "freq is required" do
    assert {:error, _} =
      RecurringEvents.unfold(@date, %{})
  end

  test "can have eathier until or count" do
    assert {:error, _} =
      RecurringEvents.unfold(@date,
                             Map.merge(@valid_rrule, %{count: 1, until: 2}))
    assert {:ok, _} =
      RecurringEvents.unfold(@date, Map.put(@valid_rrule, :until, 2))
    assert {:ok, _} =
      RecurringEvents.unfold(@date, Map.put(@valid_rrule, :count, 1))
  end
end
