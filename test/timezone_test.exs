defmodule RecurringEvents.TimezoneTest do
  use ExUnit.Case, async: true
  import RecurringEvents.TestHelper

  if Code.ensure_loaded?(Timex) do
    test "should handle timezones if Timex available" do
      time = Timex.to_datetime({{2018, 11, 2}, {5, 0, 0}}, "America/Los_Angeles")

      result =
        RecurringEvents.take(
          time,
          %{freq: :daily, by_hour: 3, by_minute: 0, by_second: 0},
          5
        )

      assert result ==
               date_tz_expand(
                 [{{2018, 11, 2}, {5, 0, 0}}, {{2018, 11, 3..6}, {3, 0, 0}}],
                 "America/Los_Angeles"
               )
    end

    def date_tz_expand(date_list, time_zone) when is_list(date_list) do
      Enum.flat_map(date_list, fn t -> date_tz_expand(t, time_zone) end)
    end

    def date_tz_expand({{years, months, days}, {hours, minutes, seconds}}, time_zone) do
      for year <- listify(years),
          month <- listify(months),
          day <- listify(days),
          hour <- listify(hours),
          minute <- listify(minutes),
          second <- listify(seconds),
          do: Timex.to_datetime({{year, month, day}, {hour, minute, second}}, time_zone)
    end
  end
end
