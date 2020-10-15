defmodule RecurringEventsTest do
  use ExUnit.Case
  doctest RecurringEvents

  alias RecurringEvents, as: RR

  @date ~D[2017-01-01]
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

  test "when time ruls provided date have to have time data" do
    assert_raise ArgumentError, "To use time rules you have to provide date with time", fn ->
      RR.unfold(@date, %{freq: :minutely})
    end

    assert_raise ArgumentError, "To use time rules you have to provide date with time", fn ->
      RR.unfold(@date, %{freq: :yearly, by_hour: 12})
    end
  end

  test "if no date provided it should raise an error" do
    assert_raise ArgumentError, "You have to use date or datetime structure", fn ->
      RR.unfold(%{}, @valid_rrule)
    end
  end

  test "will raise an exception if count is invalid" do
    assert_raise ArgumentError, fn ->
      RR.take(@date, @valid_rrule, -1)
    end

    assert_raise ArgumentError, fn ->
      RR.unfold(@date, %{freq: :yearly, count: -1})
    end
  end

  test "can handle yearly frequency" do
    events =
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

  test "can return list instead of stream" do
    stream = RR.unfold(@date, %{freq: :weekly})
    list = RR.take(@date, %{freq: :weekly}, 29)
    assert is_list(list)
    assert list == Enum.take(stream, 29)
  end

  test "can optionally return invalid dates" do
    date = ~D[2020-10-31]

    events =
      date 
      |> RR.unfold(%{freq: :monthly, invalid: :return})
      |> Enum.take(2)
    
    assert events == [date, %{date | month: 11, day: 31}]
  end

  test "can optionally skip invalid dates" do
    date = ~D[2020-10-31]

    events =
      date 
      |> RR.unfold(%{freq: :monthly, invalid: :skip})
      |> Enum.take(2)
    
    assert events == [date, %{date | month: 12, day: 31}]
  end

  test "can optionally skip invalid dates and respect count" do
    date = ~D[2020-10-31]

    events =
      date 
      |> RR.unfold(%{freq: :monthly, invalid: :skip, count: 3})
      |> Enum.take(99)
    
    assert events == [date, %{date | month: 12, day: 31}]
  end
end
