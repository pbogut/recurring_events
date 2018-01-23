defmodule RecurringEvents.ByCheckerTest do
  use ExUnit.Case
  doctest RecurringEvents.ByChecker

  alias RecurringEvents.ByChecker

  @wednesday ~D[2017-01-25]
  @monday ~D[2017-01-23]

  # :by_month rule
  test "can check if date satisfy :by_month rule" do
    assert true == @monday |> ByChecker.check(%{by_month: [1]})
    assert false == @wednesday |> ByChecker.check(%{by_month: [3]})
  end

  # :by_month_day rule
  test "can check if date satisfy :by_month_day rule" do
    assert true == @monday |> ByChecker.check(%{by_month_day: [23, 25]})
    assert true == @wednesday |> ByChecker.check(%{by_month_day: [25]})
    assert false == @wednesday |> ByChecker.check(%{by_month_day: [23]})
  end

  test "can check if date satisfy :by_month_day rule when negative number" do
    assert true == @wednesday |> ByChecker.check(%{by_month_day: [-7]})
    assert false == @monday |> ByChecker.check(%{by_month_day: [-7]})
  end

  # :by_week_number rule

  test "can check if date satisfy :by_week_number rule" do
    assert true == ~D[2017-01-24] |> ByChecker.check(%{by_week_number: [4]})
    assert false == ~D[2017-01-24] |> ByChecker.check(%{by_week_number: [5]})
  end

  test "can check if date satisfy :by_week_number rule when negative number" do
    assert true == ~D[2017-01-24] |> ByChecker.check(%{by_week_number: [-49]})
    assert true == ~D[2017-12-25] |> ByChecker.check(%{by_week_number: [-1]})
  end

  test "check if date satisfy :by_week_number rule can be affected by :week_start" do
    assert true ==
             @monday
             |> ByChecker.check(%{
               week_start: :monday,
               by_week_number: [4]
             })

    assert false ==
             @monday
             |> ByChecker.check(%{
               week_start: :tuesday,
               by_week_number: [4]
             })
  end

  # :by_year_day rule

  test "can check if date satisfy :by_year_day rule" do
    assert true == ~D[2017-01-01] |> ByChecker.check(%{by_year_day: [1]})
    assert true == ~D[2017-01-24] |> ByChecker.check(%{by_year_day: [24]})
    assert true == ~D[2017-12-24] |> ByChecker.check(%{by_year_day: [358]})
    assert true == ~D[2017-12-31] |> ByChecker.check(%{by_year_day: [365]})
    assert false == ~D[2017-12-31] |> ByChecker.check(%{by_year_day: [5]})
  end

  test "can check if date satisfy :by_year_day rule when negative number" do
    assert true == ~D[2017-12-31] |> ByChecker.check(%{by_year_day: [-1]})
    assert true == ~D[2017-12-30] |> ByChecker.check(%{by_year_day: [-2]})
    assert true == ~D[2017-12-25] |> ByChecker.check(%{by_year_day: [-7]})
    assert true == ~D[2017-01-06] |> ByChecker.check(%{by_year_day: [-360]})
    assert true == ~D[2017-01-01] |> ByChecker.check(%{by_year_day: [-365]})
    assert false == ~D[2017-01-01] |> ByChecker.check(%{by_year_day: [-35]})
  end

  # :by_day rule

  test "can check if date satisfy :by_day: rule" do
    assert true == @monday |> ByChecker.check(%{by_day: [:monday]})
    assert true == @wednesday |> ByChecker.check(%{by_day: [{-1, :wednesday}]})
    assert true == @wednesday |> ByChecker.check(%{by_day: [:friday, {7, :wednesday}]})
    assert false == @monday |> ByChecker.check(%{by_day: [:wednesday]})
    assert false == @wednesday |> ByChecker.check(%{by_day: [:saturday, :friday]})
  end

  test "day can be provided as a touple with month day number when freq: monthly" do
    assert true == @wednesday |> ByChecker.check(%{by_day: [{-1, :wednesday}], freq: :monthly})
    assert true == @wednesday |> ByChecker.check(%{by_day: [{4, :wednesday}], freq: :monthly})
    assert false == @wednesday |> ByChecker.check(%{by_day: [{-2, :wednesday}], freq: :monthly})
    assert false == @wednesday |> ByChecker.check(%{by_day: [{3, :wednesday}], freq: :monthly})
  end

  test "day can be provided as a touple with year day number when freq :yearly" do
    assert true == @wednesday |> ByChecker.check(%{by_day: [{-49, :wednesday}], freq: :yearly})
    assert true == @wednesday |> ByChecker.check(%{by_day: [{4, :wednesday}], freq: :yearly})
    assert false == @wednesday |> ByChecker.check(%{by_day: [{-1, :wednesday}], freq: :yearly})
    assert false == @wednesday |> ByChecker.check(%{by_day: [{3, :wednesday}], freq: :yearly})
  end
end
