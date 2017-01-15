defmodule RecurringEvents.DateTest do
  use ExUnit.Case
  doctest RecurringEvents

  alias RecurringEvents.Date

  @date ~N[2017-01-30 10:00:00]

  test "can shift date by N days" do
    assert ~N[2017-01-31 10:00:00] ==
      Date.shift_date(@date, 1, :days)
    assert ~N[2017-02-01 10:00:00] ==
      Date.shift_date(@date, 2, :days)
    assert ~N[2018-01-30 10:00:00] ==
      Date.shift_date(@date, 365, :days)
  end
end
