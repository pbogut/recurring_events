ExUnit.configure(exclude: [pending: true])
ExUnit.start()

defmodule RecurringEvents.TestHelper do
  def listify({a, b, c}), do: {listify(a), listify(b), listify(c)}
  def listify({a, b}), do: {listify(a), listify(b)}
  def listify(a) when is_integer(a), do: [a]
  def listify(a), do: a


  def date_expand(date_list) when is_list(date_list) do
    Enum.flat_map(date_list, &date_expand/1)
  end

  def date_expand({{years, months, days}, {hours, minutes, seconds}}) do
    for year <- listify(years),
        month <- listify(months),
        day <- listify(days),
        hour <- listify(hours),
        minute <- listify(minutes),
        second <- listify(seconds),
        do: NaiveDateTime.from_erl!({{year, month, day}, {hour, minute, second}})
  end

  def date_expand({years, months, days}) do
    for year <- listify(years),
        month <- listify(months),
        day <- listify(days),
        do: Date.from_erl!({year, month, day})
  end
end
