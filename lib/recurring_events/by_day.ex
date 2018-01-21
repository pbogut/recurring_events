defmodule RecurringEvents.ByDay do
  @moduledoc """
  Handles `:by_day` rule
  """

  use RecurringEvents.Guards
  alias RecurringEvents.{Date, CommonBy}

  @doc """
  Applies `:by_day` rule to given date and returns enumerable.
  Depends on other rules it may create additional dates keep one provided
  or remove it. See tests for details.

  # Examples

      iex> RecurringEvents.ByDay.unfold(~D[2017-01-22],
      ...>       %{freq: :weekly, by_day: :monday})
      ...> |> Enum.take(10)
      [~D[2017-01-16]]

      iex> RecurringEvents.ByDay.unfold(~D[2017-01-22],
      ...>       %{freq: :monthly, by_day: :sunday})
      ...> |> Enum.take(10)
      [~D[2017-01-01], ~D[2017-01-08], ~D[2017-01-15], ~D[2017-01-22],
       ~D[2017-01-29]]

  """
  def unfold(date, %{by_day: day} = rules, action) when not is_list(day) do
    unfold(date, %{rules | by_day: [day]}, action)
  end

  def unfold(date, rules, :filter) do
    case rules do
      %{by_day: days} ->
        CommonBy.filter(date, &is_week_day_in(&1, days))

      _ ->
        [date]
    end
  end

  def unfold(date, rules, :inflate) do
    case rules do
      %{by_day: days, by_month: _} ->
        CommonBy.inflate(date, rules, &is_week_day_in(&1, days, :month))

      %{by_day: days, freq: :weekly} ->
        CommonBy.inflate(date, rules, &is_week_day_in(&1, days))

      %{by_day: days, freq: :monthly} ->
        CommonBy.inflate(date, rules, &is_week_day_in(&1, days, :month))

      %{by_day: days, freq: :yearly} ->
        CommonBy.inflate(date, rules, &is_week_day_in(&1, days, :year))

      _ ->
        [date]
    end
  end

  defp is_week_day_in(date, days) do
    Enum.any?(days, &is_week_day_eq(date, &1))
  end

  defp is_week_day_in(date, days, period) do
    Enum.any?(days, &is_week_day_eq(date, &1, period))
  end

  defp is_week_day_eq(date, {_, week_day}) do
    is_week_day_eq(date, week_day)
  end

  defp is_week_day_eq(date, week_day) do
    Date.week_day(date) == week_day
  end

  defp is_week_day_eq(date, {n, _} = week_day, period) when n < 0 do
    Date.numbered_week_day(date, period, :backward) == week_day
  end

  defp is_week_day_eq(date, {n, _} = week_day, period) when n > 0 do
    Date.numbered_week_day(date, period, :foreward) == week_day
  end

  defp is_week_day_eq(date, week_day, _period) when is_atom(week_day) do
    is_week_day_eq(date, week_day)
  end
end
