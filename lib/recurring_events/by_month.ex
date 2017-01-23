defmodule RecurringEvents.ByMonth do
  use RecurringEvents.Guards
  alias RecurringEvents.Date

  def unfold(dates, %{by_month: month} = params, range)
  when is_integer(month) do
    unfold(dates, %{params | by_month: [month]}, range)
  end

  def unfold(dates, %{by_month: _months, freq: :yearly} = params, _range) do
    inflate(dates, params)
  end

  def unfold(dates, %{by_month: _months, freq: freq} = params, _range)
  when is_freq_valid(freq) do
    filter(dates, params)
  end

  def unfold(dates, %{}, _range) do
    dates
  end

  defp filter(dates, %{by_month: months}) do
    Enum.filter(dates, fn date ->
      Enum.any?(months, fn month ->
        month == date.month
      end)
    end)
  end

  defp inflate(dates, %{by_month: months}) do
    Enum.flat_map(dates, fn date ->
      Enum.map(months, fn month ->
        day = Date.last_day_of_the_month(%{date | month: month})
        %{date | month: month, day: min(day, date.day)}
      end)
    end)
  end
end
