defmodule RecurringEvents.ByMonth do
  @moduledoc """
  Handles `:by_month` rule
  """

  alias RecurringEvents.{Date, Guards, CommonBy}
  use Guards

  @doc """
  Applies `:by_month` rule to given date and returns enumerable.
  Depends on other rules it may create additional dates keep one provided
  or remove it. See tests for details.

  # Examples

      iex> RecurringEvents.ByMonth.unfold(~D[2017-01-22],
      ...>       %{freq: :yearly, by_month: [1, 2, 3]})
      ...> |> Enum.take(10)
      [~D[2017-01-22], ~D[2017-02-22], ~D[2017-03-22]]

      iex> RecurringEvents.ByMonth.unfold(~D[2017-01-22],
      ...>       %{freq: :monthly, by_month: [1, 2, 3]})
      ...> |> Enum.take(10)
      [~D[2017-01-22]]

  """
  def unfold(date, %{by_month: month} = rules, action)
      when is_integer(month) do
    unfold(date, %{rules | by_month: [month]}, action)
  end

  def unfold(date, %{by_month: _months, freq: :yearly} = rules, :inflate) do
    inflate(date, rules)
  end

  def unfold(date, %{by_month: months, freq: freq}, :filter) when is_freq_valid(freq) do
    CommonBy.filter(date, &is_month_in(&1, months))
  end

  def unfold(date, %{}, _) do
    [date]
  end

  defp is_month_in(date, months) do
    Enum.any?(months, fn month -> month == date.month end)
  end

  defp inflate(date, %{by_month: months}) do
    Stream.map(months, fn month ->
      day = Date.last_day_of_the_month(%{date | month: month})
      %{date | month: month, day: min(day, date.day)}
    end)
  end
end
