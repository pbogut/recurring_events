defmodule RecurringEvents.ByMonthTest do
  use ExUnit.Case
  doctest RecurringEvents.ByMonth

  alias RecurringEvents.ByMonth

  @dates [
    ~D[2017-01-20], ~D[2017-04-21], ~D[2017-07-22], ~D[2017-10-23],
    ~D[2017-02-24], ~D[2017-05-25], ~D[2017-08-26], ~D[2017-11-27],
    ~D[2017-03-28], ~D[2017-06-29], ~D[2017-09-30], ~D[2017-12-31],
  ]

  @years [
    ~D[2017-01-20], ~D[2018-04-21], ~D[2019-07-22], ~D[2020-10-30],
  ]

  test "can filter by month when freq: :daily" do
    assert [~D[2017-01-20]] ==
      ByMonth.unfold(@dates, %{freq: :daily, by_month: 1}, {})
    assert [~D[2017-02-24], ~D[2017-05-25], ~D[2017-09-30]] ==
      ByMonth.unfold(@dates, %{freq: :daily, by_month: [2,5,9]}, {})
  end

  test "can filter by month when freq: :weekly" do
    assert [~D[2017-01-20]] ==
      ByMonth.unfold(@dates, %{freq: :weekly, by_month: 1}, {})
    assert [~D[2017-02-24], ~D[2017-05-25], ~D[2017-09-30]] ==
      ByMonth.unfold(@dates, %{freq: :weekly, by_month: [2,5,9]}, {})
  end

  test "can filter by month when freq: :monthly" do
    assert [~D[2017-01-20]] ==
      ByMonth.unfold(@dates, %{freq: :monthly, by_month: 1}, {})
    assert [~D[2017-02-24], ~D[2017-05-25], ~D[2017-09-30]] ==
      ByMonth.unfold(@dates, %{freq: :monthly, by_month: [2,5,9]}, {})
  end

  test "can inflate months when freq: :yearly" do
    assert [~D[2017-02-20], ~D[2018-02-21], ~D[2019-02-22], ~D[2020-02-29]] ==
      ByMonth.unfold(@years, %{freq: :yearly, by_month: 2}, {})
    assert [~D[2017-02-20], ~D[2017-05-20], ~D[2018-02-21], ~D[2018-05-21],
            ~D[2019-02-22], ~D[2019-05-22], ~D[2020-02-29], ~D[2020-05-30]] ==
      ByMonth.unfold(@years, %{freq: :yearly, by_month: [2,5]}, {})
  end
end
