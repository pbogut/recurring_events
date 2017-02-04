defmodule RecurringEvents.ByMonth do
  alias RecurringEvents.{Date, Guards}
  use Guards

  def unfold(date, %{by_month: month} = params)
  when is_integer(month) do
    unfold(date, %{params | by_month: [month]})
  end

  def unfold(date, %{by_month: _months, freq: :yearly} = params) do
    inflate(date, params)
  end

  def unfold(date, %{by_month: _months, freq: freq} = params)
  when is_freq_valid(freq) do
    filter(date, params)
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
