defmodule RecurringEventsTest do
  use ExUnit.Case
  doctest RecurringEvents

  alias RecurringEvents, as: RR

  @date ~N[2017-01-01 10:00:00]
  @valid_rrule %{freq: :yearly}

  test "freq is required" do
    assert_raise ArgumentError, "Frequency is required", fn ->
      RR.unfold(@date, %{})
    end
  end

  test "will rise error if frequency is invalid" do
    assert_raise ArgumentError, "Frequency is invalid", fn ->
      RR.unfold(@date, %{freq: :whatever})
    end
  end

  test "can have eathier until or count" do
    assert_raise ArgumentError, "Can have either, count or until", fn ->
      RR.unfold(@date, Map.merge(@valid_rrule, %{count: 1, until: 2}))
    end
  end

  test "can handle yearly frequency" do
    events  =
      @date
      |> RR.unfold(%{freq: :yearly})
      |> Enum.take(3)
    assert 3 = Enum.count(events)
  end

  test "can handle monthly frequency" do
    events =
      @date
      |> RR.unfold(%{freq: :monthly})
      |> Enum.take(36)
    assert 36 = Enum.count(events)
  end

  test "can handle daily frequency" do
    events =
      @date
      |> RR.unfold(%{freq: :daily})
      |> Enum.take(90)
    assert 90 = Enum.count(events)
  end

  test "can handle weekly frequency" do
    events =
      @date
      |> RR.unfold(%{freq: :weekly})
      |> Enum.take(13)
    assert 13 = Enum.count(events)
  end
end
