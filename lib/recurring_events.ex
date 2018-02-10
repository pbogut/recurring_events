defmodule RecurringEvents do
  @moduledoc """
  *RecurringEvents* is an Elixir library providing recurring events support
  (duh!).

  It loosely follows
  [iCal Recurrence rule specification](http://www.kanzaki.com/docs/ical/rrule.html)
  [RFC 2445](https://tools.ietf.org/html/rfc2445).

  Currently, it is ignoring time but if DateTime or NaiveDateTime structure
  is used time will be preserved (see below).

      iex> RecurringEvents.take(~D[2016-12-07], %{freq: :daily}, 3)
      [~D[2016-12-07], ~D[2016-12-08], ~D[2016-12-09]]

      iex> RecurringEvents.take(~N[2016-01-17 12:21:06], %{freq: :weekly}, 2)
      [~N[2016-01-17 12:21:06], ~N[2016-01-24 12:21:06]]

  Currently supported rules

    - `:count` - how many occurences should be return
    - `:interval` - how often recurrence rule repeats
    - `:freq` - this is the only required rule, possible values: `:yearly`,
      `:monthly`, `:weekly`, `:daily`, `:hourly`, `:minutely`, `:secondly`
    - `:week_start` - start day of the week, see `:by_day` for possible values
    - `:by_month` - month number or list of month numbers
    - `:by_day` - day or list of days, possible values: `:monday`, `:tuesday`,
      `:wednesday`, `:thursday`, `:friday`, `:saturday`, `:sunday`.
      This rule can also accept tuples with occurrence number when used with
      `:monthly` or `:yearly` frequency (e.g. `{3, :monday}` for 3rd Monday or
      `{-2, :tuesday}` for 2nd to last Tuesday)
    - `:by_month_day` - month day number or list of month day numbers
    - `:by_week_number` - number of the week in a year, first week should have at
      least 4 days, `:week_start` may affect result of this rule
    - `:by_year_day` - number of the day in a year `1` is the first `-1` is the last
    - `:by_hour` - hour from 0 to 23
    - `:by_minute` - minute from 0 to 59
    - `:by_second` - second from 0 to 59
    - `:by_set_position` - if present, this indicates the nth occurrence of the
      date withing frequency period
    - `:exclude_date` - dates to be excluded from the result
    - `:until` - limit result up to provided date

  For more usage examples, please, refer to
  [tests](https://github.com/pbogut/recurring_events/blob/master/test/ical_rrul_test.exs)

  """

  alias RecurringEvents.{
    Date,
    Guards,
    Yearly,
    Monthly,
    Frequency,
    Weekly,
    ByPump,
    ByChecker
  }

  use Guards

  @rules [
    :by_month_day,
    :by_year_day,
    :by_day,
    :by_week_number,
    :by_month,
    :by_hour,
    :by_minute,
    :by_second,
    :by_set_position,
    :exclude_date
  ]

  @doc """
  Returns stream of recurring events based on date and rules

  # Example

      iex> RecurringEvents.unfold(~D[2014-06-07], %{freq: :yearly})
      ...> |> Enum.take(3)
      [~D[2014-06-07], ~D[2015-06-07], ~D[2016-06-07]]

  """
  def unfold(date, rules) do
    validate(date, rules)
    do_unfold(date, listify(rules))
  end

  @doc """
  Returns list of recurring events based on date and rules

  # Example

      iex> RecurringEvents.take(~D[2015-09-13], %{freq: :monthly}, 4)
      [~D[2015-09-13], ~D[2015-10-13], ~D[2015-11-13], ~D[2015-12-13]]

  """
  def take(date, rules, count) do
    date |> unfold(rules) |> Enum.take(count)
  end

  defp do_unfold(date, %{freq: freq} = rules) do
    date
    |> get_freq_module(freq).unfold(rules)
    |> by_rules(rules)
    |> by_set_position(rules)
    |> drop_before(date)
    |> prepend(date)
    |> drop_after(rules)
    |> drop_exclude(rules)
  end

  defp drop_exclude(dates, %{exclude_date: excludes}) do
    dates |> Stream.filter(&(&1 not in excludes))
  end

  defp drop_exclude(dates, _) do
    dates
  end

  defp by_rules(dates, rules) do
    dates
    |> Stream.flat_map(&ByPump.inflate(&1, rules))
    |> Stream.filter(&ByChecker.check(&1, rules))
  end

  defp drop_before(list, date) do
    Stream.drop_while(list, &(Date.compare(date, &1) != :lt))
  end

  defp drop_after(list, %{until: date}) do
    Stream.take_while(list, &(Date.compare(date, &1) != :lt))
  end

  defp drop_after(list, %{count: count}), do: Stream.take(list, count)
  defp drop_after(list, %{}), do: list

  defp prepend(list, element), do: Stream.concat([element], list)

  defp get_freq_module(:yearly), do: Yearly
  defp get_freq_module(:monthly), do: Monthly
  defp get_freq_module(:weekly), do: Weekly
  defp get_freq_module(:daily), do: Frequency
  defp get_freq_module(:hourly), do: Frequency
  defp get_freq_module(:minutely), do: Frequency
  defp get_freq_module(:secondly), do: Frequency

  defp listify(%{freq: _} = rules) do
    Enum.reduce(@rules, rules, fn key, rules ->
      case Map.get(rules, key, nil) do
        nil -> rules
        value -> %{rules | key => listify(value)}
      end
    end)
  end

  defp listify(list) when is_list(list), do: list
  defp listify(item) when not is_list(item), do: [item]

  defp by_set_position(dates, %{by_set_position: positions} = rules) do
    dates
    |> Stream.chunk_by(chunk_func(rules))
    |> Stream.flat_map(&get_at_positions(&1, positions))
  end

  defp get_at_positions(date, positions) do
    positions
    |> Enum.map(fn position -> get_position(date, position) end)
    |> Enum.filter(fn date -> date != nil end)
  end

  defp by_set_position(dates, _rules), do: dates

  defp get_position(dates, position) do
    cond do
      position > 0 -> Enum.at(dates, position - 1)
      position < 0 -> dates |> Enum.reverse() |> Enum.at(-position - 1)
    end
  end

  defp chunk_func(%{freq: :yearly}), do: fn date -> date.year end
  defp chunk_func(%{freq: :monthly}), do: fn date -> date.month end
  defp chunk_func(%{freq: :daily}), do: fn date -> date.day end

  defp chunk_func(%{freq: :weekly} = rules) do
    &Date.week_number(&1, week_start: week_start(rules))
  end

  defp week_start(%{week_start: week_start}), do: week_start
  defp week_start(_), do: :monday

  defp validate(date, rules) do
    freq = Map.get(rules, :freq)

    cond do
      !freq ->
        raise ArgumentError, message: "Frequency is required"

      !is_freq_valid(freq) ->
        raise ArgumentError, message: "Frequency is invalid"

      Map.has_key?(rules, :count) and Map.has_key?(rules, :until) ->
        raise ArgumentError, message: "Can have either, count or until"

      !is_date(date) ->
        raise ArgumentError, message: "You have to use date or datetime structure"

      (is_time_freq(freq) or has_time_rule(rules)) and not has_time(date) ->
        raise ArgumentError, message: "To use time rules you have to provide date with time"

      true ->
        nil
    end
  end
end
