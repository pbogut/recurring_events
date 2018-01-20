defmodule RecurringEvents.ByMonth do
  @moduledoc """
  Handles `:by_month` rule
  """

  alias RecurringEvents.{Date, Guards}
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
  def unfold(date, %{by_month: month} = rules)
      when is_integer(month) do
    unfold(date, %{rules | by_month: [month]})
  end

  def unfold(date, %{by_month: _months, freq: :yearly} = rules) do
    inflate(date, rules)
  end

  def unfold(date, %{by_month: _months, freq: freq} = rules)
      when is_freq_valid(freq) do
    filter(date, rules)
  end

  def unfold(date, %{}) do
    [date]
  end

  defp filter(date, %{by_month: months}) do
    if Enum.any?(months, fn month -> month == date.month end) do
      [date]
    else
      []
    end
  end

  defp inflate(date, %{by_month: months}) do
    Stream.map(months, fn month ->
      day = Date.last_day_of_the_month(%{date | month: month})
      %{date | month: month, day: min(day, date.day)}
    end)
  end
end
