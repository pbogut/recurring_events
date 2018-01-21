defmodule RecurringEvents.ByYearDayTest do
  use ExUnit.Case
  doctest RecurringEvents.ByYearDay

  alias RecurringEvents.ByYearDay

  test "should filter when freq :daily" do
    assert [~D[2017-01-01]] ==
             ByYearDay.unfold(~D[2017-01-01], %{by_year_day: [1, 2, 3], freq: :daily})

    assert [] == ByYearDay.unfold(~D[2017-01-01], %{by_year_day: 7, freq: :daily})
  end

  test "should inflate when freq not :daily" do
    assert [~D[2017-01-01], ~D[2017-01-02], ~D[2017-01-07]] ==
             ByYearDay.unfold(~D[2017-01-01], %{by_year_day: [1, 2, 7], freq: :monthly})
             |> Enum.take(10)

    assert [~D[2017-01-09]] ==
             ByYearDay.unfold(~D[2017-01-01], %{by_year_day: 9, freq: :yearly})
             |> Enum.take(10)
  end
end
