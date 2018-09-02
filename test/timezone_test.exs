defmodule RecurringEvents.TimezoneTest do
  use ExUnit.Case, async: true
  import RecurringEvents.TestHelper
  alias RecurringEvents, as: RR

  if Code.ensure_loaded?(Timex) do
    test "should handle timezones if Timex available" do
      time = Timex.to_datetime({{2018, 11, 2}, {5, 0, 0}}, "America/Los_Angeles")

      result =
        RR.take(
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

    @doc """
      Every other week - forever

      DTSTART;TZID=US-Eastern:19970902T090000
      RRULE:FREQ=WEEKLY;INTERVAL=2;WKST=SU

      ==> (1997 9:00 AM EDT)September 2,16,30;October 14
          (1997 9:00 AM EST)October 28;November 11,25;December 9,23
          (1998 9:00 AM EST)January 6,20;February
      ...
    """
    test "Every other week - forever" do
      result =
        Timex.to_datetime({1997, 9, 2}, "America/Los_Angeles")
        |> RR.unfold(%{freq: :weekly, interval: 2, week_start: :sunday})

      expect =
        date_tz_expand(
          [
            {1997, 9, [2, 16, 30]},
            {1997, 10, [14, 28]},
            {1997, 11, [11, 25]},
            {1997, 12, [9, 23]},
            {1998, 1, [6, 20]}
          ],
          "America/Los_Angeles"
        )

      assert expect == result |> Enum.take(expect |> Enum.count())
    end

    @doc """
      Every other month on the 1st and last Sunday of the month for 10
      occurrences:

      DTSTART;TZID=US-Eastern:19970907T090000
      RRULE:FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU

      ==> (1997 9:00 AM EDT)September 7,28
          (1997 9:00 AM EST)November 2,30
          (1998 9:00 AM EST)January 4,25;March 1,29
          (1998 9:00 AM EDT)May 3,31
    """
    test "Every other month on the 1st and last Sunday of the month for 10 occurrences" do
      result =
        Timex.to_datetime({1997, 9, 7}, "America/Los_Angeles")
        |> RR.unfold(%{
          freq: :monthly,
          interval: 2,
          count: 10,
          by_day: [{1, :sunday}, {-1, :sunday}]
        })

      expect =
        date_tz_expand(
          [
            {1997, 9, [7, 28]},
            {1997, 11, [2, 30]},
            {1998, 1, [4, 25]},
            {1998, 3, [1, 29]},
            {1998, 5, [3, 31]}
          ],
          "America/Los_Angeles"
        )

      assert expect == result |> Enum.take(999)
    end

    @doc """
      Weekly until December 24, 1997

      DTSTART;TZID=US-Eastern:19970902T090000
      RRULE:FREQ=WEEKLY;UNTIL=19971224T000000Z

      ==> (1997 9:00 AM EDT)September 2,9,16,23,30;October 7,14,21
          (1997 9:00 AM EST)October 28;November 4,11,18,25;
                            December 2,9,16,23
    """
    test "Weekly until December 24, 1997" do
      result =
        Timex.to_datetime({1997, 9, 2}, "America/Los_Angeles")
        |> RR.unfold(%{
          freq: :weekly,
          until: Timex.to_datetime({1997, 12, 24}, "America/Los_Angeles")
        })

      expect =
        date_tz_expand(
          [
            {1997, 9, [2, 9, 16, 23, 30]},
            {1997, 10, [7, 14, 21, 28]},
            {1997, 11, [4, 11, 18, 25]},
            {1997, 12, [2, 9, 16, 23]}
          ],
          "America/Los_Angeles"
        )

      assert expect == result |> Enum.take(999)
    end

    @doc """
      Weekly for 10 occurrences

      DTSTART;TZID=US-Eastern:19970902T090000
      RRULE:FREQ=WEEKLY;COUNT=10

      ==> (1997 9:00 AM EDT)September 2,9,16,23,30;October 7,14,21
          (1997 9:00 AM EST)October 28;November 4
    """
    test "Weekly for 10 occurrences" do
      result =
        Timex.to_datetime({1997, 9, 2}, "America/Los_Angeles")
        |> RR.unfold(%{freq: :weekly, count: 10})

      expect =
        date_tz_expand(
          [
            {1997, 9, [2, 9, 16, 23, 30]},
            {1997, 10, [7, 14, 21, 28]},
            {1997, 11, 4}
          ],
          "America/Los_Angeles"
        )

      assert expect == result |> Enum.take(999)
    end

    @doc """
      Monthly on the first and last day of the month for 10 occurrences

      DTSTART;TZID=US-Eastern:19970930T090000
      RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=1,-1

      ==> (1997 9:00 AM EDT)September 30;October 1
          (1997 9:00 AM EST)October 31;November 1,30;December 1,31
          (1998 9:00 AM EST)January 1,31;February 1
    """
    test "Monthly on the first and last day of the month for 10 occurrences" do
      result =
        Timex.to_datetime({1997, 9, 30}, "America/Los_Angeles")
        |> RR.unfold(%{
          freq: :monthly,
          count: 10,
          by_month_day: [1, -1]
        })

      expect =
        date_tz_expand(
          [
            {1997, 9, 30},
            {1997, 10, [1, 31]},
            {1997, 11, [1, 30]},
            {1997, 12, [1, 31]},
            {1998, 1, [1, 31]},
            {1998, 2, 1}
          ],
          "America/Los_Angeles"
        )

      assert expect == result |> Enum.take(999)
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

    def date_tz_expand({years, months, days}, time_zone) do
      for year <- listify(years),
          month <- listify(months),
          day <- listify(days),
          do: Timex.to_datetime({year, month, day}, time_zone)
    end
  end
end
