defmodule RecurringEventsTest do
  use ExUnit.Case
  doctest RecurringEvents

  @date ~N[2017-01-01 10:00:00]
  @valid_rrule %{freq: :yearly}

  test "freq is required" do
    assert {:error, _} =
      RecurringEvents.unfold(@date, %{})
  end

  test "can have eathier until or count" do
    assert {:error, _} =
      RecurringEvents.unfold(@date,
                             Map.merge(@valid_rrule, %{count: 1, until: 2}))
    assert {:ok, _} =
      RecurringEvents.unfold(@date, Map.put(@valid_rrule, :until, @date))
    assert {:ok, _} =
      RecurringEvents.unfold(@date, Map.put(@valid_rrule, :count, 1))
  end

  test "can handle yearly frequency" do
    events  =
      @date
      |> RecurringEvents.unfold!(%{freq: :yearly})
      |> Enum.take(3)
    assert 3 = Enum.count(events)
  end

  test "can handle monthly frequency" do
    events =
      @date
      |> RecurringEvents.unfold!(%{freq: :monthly})
      |> Enum.take(36)
    assert 36 = Enum.count(events)
  end

  test "can handle daily frequency" do
    events =
      @date
      |> RecurringEvents.unfold!(%{freq: :daily})
      |> Enum.take(90)
    assert 90 = Enum.count(events)
  end

  test "can handle weekly frequency" do
    events =
      @date
      |> RecurringEvents.unfold!(%{freq: :weekly})
      |> Enum.take(13)
    assert 13 = Enum.count(events)
  end
end
