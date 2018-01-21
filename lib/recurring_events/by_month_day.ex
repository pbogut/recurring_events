defmodule RecurringEvents.ByMonthDay do
  @moduledoc """
  Handles `:by_month_day` rule
  """

  use RecurringEvents.Guards
  alias RecurringEvents.{Date, CommonBy}

  @doc """
  Applies `:by_month_day` rule to given date and returns enumerable.
  Depends on other rules it may create additional dates keep one provided
  or remove it. See tests for details.

  # Examples

     iex> RecurringEvents.ByMonthDay.unfold(~D[2017-01-22],
     ...>       %{freq: :weekly, by_month_day: [18, 31]})
     ...> |> Enum.take(10)
     [~D[2017-01-18]]

     iex> RecurringEvents.ByMonthDay.unfold(~D[2017-01-22],
     ...>       %{freq: :monthly, by_month_day: [1, -1]})
     ...> |> Enum.take(10)
     [~D[2017-01-01], ~D[2017-01-31]]

  """
  def unfold(date, %{by_month_day: day} = rules) when not is_list(day) do
    unfold(date, %{rules | by_month_day: [day]})
  end

  def unfold(date, rules) do
    case rules do
      %{by_month_day: days, by_week_number: _} ->
        CommonBy.filter(date, &is_month_day_in(&1, days))

      %{by_month_day: days, by_month: _} ->
        CommonBy.inflate(date, rules, &is_month_day_in(&1, days))

      %{by_month_day: days, freq: :weekly} ->
        CommonBy.inflate(date, rules, &is_month_day_in(&1, days))

      %{by_month_day: days, freq: :monthly} ->
        CommonBy.inflate(date, rules, &is_month_day_in(&1, days))

      %{by_month_day: days, freq: :yearly} ->
        CommonBy.inflate(date, rules, &is_month_day_in(&1, days))

      %{by_month_day: days, freq: :daily} ->
        CommonBy.filter(date, &is_month_day_in(&1, days))

      _ ->
        [date]
    end
  end

  defp is_month_day_in(date, days) do
    Enum.any?(days, &is_month_day_eq(date, &1))
  end

  defp is_month_day_eq(%{day: date_day}, day) when day > 0 do
    date_day == day
  end

  defp is_month_day_eq(%{day: date_day} = date, day) when day < 0 do
    date_day - (Date.last_day_of_the_month(date) + 1) == day
  end
end
