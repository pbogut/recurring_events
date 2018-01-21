defmodule RecurringEvents.ByYearDay do
  @moduledoc """
  Handles `:by_week_number` rule
  """

  alias RecurringEvents.{Date, Guards, CommonBy}
  use Guards

  @doc """
  Applies `:by_week_number` rule to given date and returns enumerable.
  Depends on other rules it may create additional dates keep one provided
  or remove it. See tests for details.

  # Examples

      iex> RecurringEvents.ByYearDay.unfold(~D[2017-01-22],
      ...>       %{freq: :yearly, by_year_day: [1,100]})
      ...> |> Enum.take(10)
      [~D[2017-01-01], ~D[2017-04-10]]

  """
  def unfold(date, %{by_year_day: number} = rules)
      when is_integer(number) do
    unfold(date, %{rules | by_year_day: [number]})
  end

  def unfold(date, rules) do
    case rules do
      %{by_year_day: numbers, freq: :daily} ->
        CommonBy.filter(date, &is_year_day_in(&1, numbers))

      %{by_year_day: numbers, by_month: _} ->
        CommonBy.inflate(date, rules, &is_year_day_in(&1, numbers))

      %{by_year_day: numbers, by_week_number: _} ->
        CommonBy.inflate(date, rules, &is_year_day_in(&1, numbers))

      %{by_year_day: numbers, freq: :monthly} ->
        CommonBy.inflate(date, rules, &is_year_day_in(&1, numbers))

      %{by_year_day: numbers, freq: :yearly} ->
        CommonBy.inflate(date, rules, &is_year_day_in(&1, numbers))

      %{by_year_day: numbers, freq: :weekly} ->
        CommonBy.inflate(date, rules, &is_year_day_in(&1, numbers))

      _ ->
        [date]
    end
  end

  defp is_year_day_in(date, numbers) do
    Enum.any?(numbers, &is_year_day(date, &1))
  end

  defp is_year_day(date, number) when number > 0 do
    Date.day_of_the_year(date) == number
  end

  defp is_year_day(%{year: year} = date, number) when number < 0 do
    last_day = if(:calendar.is_leap_year(year), do: 366, else: 365)
    last_day - Date.day_of_the_year(date) - 1 == number
  end
end
