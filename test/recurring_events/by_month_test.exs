defmodule RecurringEvents.ByMonthTest do
  use ExUnit.Case
  doctest RecurringEvents.ByMonth

  alias RecurringEvents.ByMonth

  @date ~D[2017-01-20]

  test "can filter by month when freq: :daily" do
    assert [@date] == ByMonth.unfold(@date, %{freq: :daily, by_month: Map.get(@date, :month)})
    assert [] == ByMonth.unfold(@date, %{freq: :daily, by_month: [2, 5, 9]})
    assert [@date] == ByMonth.unfold(@date, %{freq: :daily, by_month: [1, 2, 3]})
  end

  test "can filter by month when freq: :weekly" do
    assert [@date] == ByMonth.unfold(@date, %{freq: :weekly, by_month: 1})
    assert [] == ByMonth.unfold(@date, %{freq: :weekly, by_month: [2, 5, 9]})
    assert [@date] == ByMonth.unfold(@date, %{freq: :weekly, by_month: [1, 2, 3]})
  end

  test "can filter by month when freq: :monthly" do
    assert [@date] == ByMonth.unfold(@date, %{freq: :monthly, by_month: 1})
    assert [] == ByMonth.unfold(@date, %{freq: :monthly, by_month: [2, 5, 9]})
    assert [@date] == ByMonth.unfold(@date, %{freq: :monthly, by_month: [1, 2, 3]})
  end

  test "can inflate months when freq: :yearly" do
    assert [~D[2017-02-20]] ==
             @date
             |> ByMonth.unfold(%{freq: :yearly, by_month: 2})
             |> Enum.take(999)

    assert [~D[2017-02-20], ~D[2017-05-20]] ==
             @date
             |> ByMonth.unfold(%{freq: :yearly, by_month: [2, 5]})
             |> Enum.take(999)
  end
end
