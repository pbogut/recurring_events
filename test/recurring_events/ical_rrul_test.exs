defmodule RecurringEvents.IcalRrulTest do
  use ExUnit.Case, async: true
  # alias RecurringEvents.Freq.{Daily, Weekly, Monthly, Yearly}

  @range {~D[1997-09-02], ~D[2027-09-02]}

  @doc """
    Daily for 10 occurrences

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=DAILY;COUNT=10

    ==> (1997 9:00 AM EDT)September 2-11
  """
  test "Daily for 10 occurrences" do
    {:ok, result} = ~D[1997-09-02]
    |> RecurringEvents.unfold(%{freq: :daily, count: 10}, @range)

    assert date_expand({1997, 09, Enum.to_list(2..11)})
      == result |> Enum.take(999)
  end

  @doc """
    Daily until December 24, 1997

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=DAILY;UNTIL=19971224T000000Z

    ==> (1997 9:00 AM EDT)September 2-30;October 1-25
        (1997 9:00 AM EST)October 26-31;November 1-30;December 1-23
  """
  test "Daily until December 24, 1997" do
    {:ok, result} = ~D[1997-09-02]
    |> RecurringEvents.unfold(%{freq: :daily, until: ~D[1997-12-24]}, @range)

    assert date_expand([
             {1997, 09, Enum.to_list(2..30)},
             {1997, 10, Enum.to_list(1..31)},
             {1997, 11, Enum.to_list(1..30)},
             {1997, 12, Enum.to_list(1..23)},
             {1997, 12, 24} # time is not supported yet, so include last
           ]) == result |> Enum.take(999)
  end

  @doc """
    Every other day - forever

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=DAILY;INTERVAL=2
    ==> (1997 9:00 AM EDT)September2,4,6,8...24,26,28,30;
         October 2,4,6...20,22,24
        (1997 9:00 AM EST)October 26,28,30;November 1,3,5,7...25,27,29;
         Dec 1,3,...
  """
  test "Every other day - forever" do
    {:ok, result} = ~D[1997-09-02]
    |> RecurringEvents.unfold(%{freq: :daily, interval: 2}, @range)

    expect = date_expand([
      {1997, 09, [2,4,6,8,10,12,14,16,18,20,22,24,26,28,30]},
      {1997, 10, [2,4,6,8,10,12,14,16,18,20,22,24,26,28,30]},
      {1997, 11, [1,3,5,7,9,11,13,15,17,19,21,23,25,27,29]},
      {1997, 12, [1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31]},
    ])

    assert expect == Enum.take(result, Enum.count(expect))
  end

  @doc """
    Every 10 days, 5 occurrences

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=DAILY;INTERVAL=10;COUNT=5

    ==> (1997 9:00 AM EDT)September 2,12,22;October 2,12
  """
  test "Every 10 days, 5 occurrences" do
    {:ok, result} = ~D[1997-09-02]
    |> RecurringEvents.unfold(%{freq: :daily, interval: 10, count: 5}, @range)

    expect = date_expand([
      {1997, 09, [2,12,22]},
      {1997, 10, [2,12]},
    ])

    assert expect == result |> Enum.take(999)
  end

  @doc """
    Everyday in January, for 3 years

    DTSTART;TZID=US-Eastern:19980101T090000
    RRULE:FREQ=YEARLY;UNTIL=20000131T090000Z;
     BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA
    or
    RRULE:FREQ=DAILY;UNTIL=20000131T090000Z;BYMONTH=1

    ==> (1998 9:00 AM EDT)January 1-31
        (1999 9:00 AM EDT)January 1-31
        (2000 9:00 AM EDT)January 1-31
  """
  test "Everyday in January, for 3 years" do
    {:ok, result} = ~D[1998-01-01]
    |> RecurringEvents.unfold(%{freq: :daily, until: ~D[2000-01-31],
                                by_month: 1}, @range)

    expect = date_expand([
      {1998, 1, Enum.to_list(1..31)},
      {1999, 1, Enum.to_list(1..31)},
      {2000, 1, Enum.to_list(1..31)},
    ])

    assert expect == result
  end

  @doc """
    Weekly for 10 occurrences

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=WEEKLY;COUNT=10

    ==> (1997 9:00 AM EDT)September 2,9,16,23,30;October 7,14,21
        (1997 9:00 AM EST)October 28;November 4
  """
  test "Weekly for 10 occurrences" do
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
  end

  @doc """
    Weekly on Tuesday and Thursday for 5 weeks

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH
    or
    RRULE:FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH

    ==> (1997 9:00 AM EDT)September 2,4,9,11,16,18,23,25,30;October 2
  """
  test "Weekly on Tuesday and Thursday for 5 weeks" do
  end

  @doc """
    Every other week on Monday, Wednesday and Friday until December 24,
    1997, but starting on Tuesday, September 2, 1997:

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;WKST=SU;
     BYDAY=MO,WE,FR
    ==> (1997 9:00 AM EDT)September 2,3,5,15,17,19,29;October
    1,3,13,15,17
        (1997 9:00 AM EST)October 27,29,31;November 10,12,14,24,26,28;
                          December 8,10,12,22
  """
  test "Every other week on Monday, Wednesday and Friday until December 24, 1997, but starting on Tuesday, September 2, 1997:" do
  end

  @doc """
    Every other week on Tuesday and Thursday, for 8 occurrences

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=8;WKST=SU;BYDAY=TU,TH

    ==> (1997 9:00 AM EDT)September 2,4,16,18,30;October 2,14,16
  """
  test "Every other week on Tuesday and Thursday, for 8 occurrences" do
  end

  @doc """
    Monthly on the 1st Friday for ten occurrences

    DTSTART;TZID=US-Eastern:19970905T090000
    RRULE:FREQ=MONTHLY;COUNT=10;BYDAY=1FR

    ==> (1997 9:00 AM EDT)September 5;October 3
        (1997 9:00 AM EST)November 7;Dec 5
        (1998 9:00 AM EST)January 2;February 6;March 6;April 3
        (1998 9:00 AM EDT)May 1;June 5
  """
  test "Monthly on the 1st Friday for ten occurrences" do
  end

  @doc """
    Monthly on the 1st Friday until December 24, 1997

    DTSTART;TZID=US-Eastern:19970905T090000
    RRULE:FREQ=MONTHLY;UNTIL=19971224T000000Z;BYDAY=1FR

    ==> (1997 9:00 AM EDT)September 5;October 3
        (1997 9:00 AM EST)November 7;December 5

  Every other month on the 1st and last Sunday of the month for 10
  occurrences:

    DTSTART;TZID=US-Eastern:19970907T090000
    RRULE:FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU

    ==> (1997 9:00 AM EDT)September 7,28
        (1997 9:00 AM EST)November 2,30
        (1998 9:00 AM EST)January 4,25;March 1,29
        (1998 9:00 AM EDT)May 3,31
  """
  test "Monthly on the 1st Friday until December 24, 1997" do
  end

  @doc """
    Monthly on the second to last Monday of the month for 6 months

    DTSTART;TZID=US-Eastern:19970922T090000
    RRULE:FREQ=MONTHLY;COUNT=6;BYDAY=-2MO

    ==> (1997 9:00 AM EDT)September 22;October 20
        (1997 9:00 AM EST)November 17;December 22
        (1998 9:00 AM EST)January 19;February 16
  """
  test "Monthly on the second to last Monday of the month for 6 months" do
  end

  @doc """
    Monthly on the third to the last day of the month, forever

    DTSTART;TZID=US-Eastern:19970928T090000
    RRULE:FREQ=MONTHLY;BYMONTHDAY=-3

    ==> (1997 9:00 AM EDT)September 28
        (1997 9:00 AM EST)October 29;November 28;December 29
        (1998 9:00 AM EST)January 29;February 26
    ...
  """
  test "Monthly on the third to the last day of the month, forever" do
  end

  @doc """
    Monthly on the 2nd and 15th of the month for 10 occurrences

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=2,15

    ==> (1997 9:00 AM EDT)September 2,15;October 2,15
        (1997 9:00 AM EST)November 2,15;December 2,15
        (1998 9:00 AM EST)January 2,15
  """
  test "Monthly on the 2nd and 15th of the month for 10 occurrences" do
  end

  @doc """
    Monthly on the first and last day of the month for 10 occurrences

    DTSTART;TZID=US-Eastern:19970930T090000
    RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=1,-1

    ==> (1997 9:00 AM EDT)September 30;October 1
        (1997 9:00 AM EST)October 31;November 1,30;December 1,31
        (1998 9:00 AM EST)January 1,31;February 1

  Every 18 months on the 10th thru 15th of the month for 10
  occurrences:

    DTSTART;TZID=US-Eastern:19970910T090000
    RRULE:FREQ=MONTHLY;INTERVAL=18;COUNT=10;BYMONTHDAY=10,11,12,13,14,
     15

    ==> (1997 9:00 AM EDT)September 10,11,12,13,14,15
        (1999 9:00 AM EST)March 10,11,12,13
  """
  test "Monthly on the first and last day of the month for 10 occurrences" do
  end

  @doc """
    Every Tuesday, every other month

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=MONTHLY;INTERVAL=2;BYDAY=TU

    ==> (1997 9:00 AM EDT)September 2,9,16,23,30
        (1997 9:00 AM EST)November 4,11,18,25
        (1998 9:00 AM EST)January 6,13,20,27;March 3,10,17,24,31
    ...
  """
  test "Every Tuesday, every other month" do
  end

  @doc """
    Yearly in June and July for 10 occurrences

    DTSTART;TZID=US-Eastern:19970610T090000
    RRULE:FREQ=YEARLY;COUNT=10;BYMONTH=6,7
    ==> (1997 9:00 AM EDT)June 10;July 10
        (1998 9:00 AM EDT)June 10;July 10
        (1999 9:00 AM EDT)June 10;July 10
        (2000 9:00 AM EDT)June 10;July 10
        (2001 9:00 AM EDT)June 10;July 10
    Note: Since none of the BYDAY, BYMONTHDAY or BYYEARDAY components
    are specified, the day is gotten from DTSTART
  """
  test "Yearly in June and July for 10 occurrences" do
  end

  @doc """
    Every other year on January, February, and March for 10 occurrences

    DTSTART;TZID=US-Eastern:19970310T090000
    RRULE:FREQ=YEARLY;INTERVAL=2;COUNT=10;BYMONTH=1,2,3

    ==> (1997 9:00 AM EST)March 10
        (1999 9:00 AM EST)January 10;February 10;March 10
        (2001 9:00 AM EST)January 10;February 10;March 10
        (2003 9:00 AM EST)January 10;February 10;March 10
  """
  test "Every other year on January, February, and March for 10 occurrences" do
  end

  @doc """
    Every 3rd year on the 1st, 100th and 200th day for 10 occurrences

    DTSTART;TZID=US-Eastern:19970101T090000
    RRULE:FREQ=YEARLY;INTERVAL=3;COUNT=10;BYYEARDAY=1,100,200

    ==> (1997 9:00 AM EST)January 1
        (1997 9:00 AM EDT)April 10;July 19
        (2000 9:00 AM EST)January 1
        (2000 9:00 AM EDT)April 9;July 18
        (2003 9:00 AM EST)January 1
        (2003 9:00 AM EDT)April 10;July 19
        (2006 9:00 AM EST)January 1
  """
  test "Every 3rd year on the 1st, 100th and 200th day for 10 occurrences" do
  end

  @doc """
    Every 20th Monday of the year, forever

    DTSTART;TZID=US-Eastern:19970519T090000
    RRULE:FREQ=YEARLY;BYDAY=20MO

    ==> (1997 9:00 AM EDT)May 19
        (1998 9:00 AM EDT)May 18
        (1999 9:00 AM EDT)May 17
    ...

  """
  test "Every 20th Monday of the year, forever" do
  end

  @doc """
    Monday of week number 20 (where the default start of the week is Monday), forever

    DTSTART;TZID=US-Eastern:19970512T090000
    RRULE:FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO

    ==> (1997 9:00 AM EDT)May 12
        (1998 9:00 AM EDT)May 11
        (1999 9:00 AM EDT)May 17
    ...
  """
  test "Monday of week number 20 (where the default start of the week is Monday), forever" do
  end

  @doc """
    Every Thursday in March, forever

    DTSTART;TZID=US-Eastern:19970313T090000
    RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=TH

    ==> (1997 9:00 AM EST)March 13,20,27
        (1998 9:00 AM EST)March 5,12,19,26
        (1999 9:00 AM EST)March 4,11,18,25
    ...
  """
  test "Every Thursday in March, forever" do
  end

  @doc """
    Every Thursday, but only during June, July, and August, forever

    DTSTART;TZID=US-Eastern:19970605T090000
    RRULE:FREQ=YEARLY;BYDAY=TH;BYMONTH=6,7,8

    ==> (1997 9:00 AM EDT)June 5,12,19,26;July 3,10,17,24,31;
                      August 7,14,21,28
        (1998 9:00 AM EDT)June 4,11,18,25;July 2,9,16,23,30;
                      August 6,13,20,27
        (1999 9:00 AM EDT)June 3,10,17,24;July 1,8,15,22,29;
                      August 5,12,19,26
    ...
  """
  test "Every Thursday, but only during June, July, and August, forever" do
  end

  @doc """
    Every Friday the 13th, forever

    DTSTART;TZID=US-Eastern:19970902T090000
    EXDATE;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13

    ==> (1998 9:00 AM EST)February 13;March 13;November 13
        (1999 9:00 AM EDT)August 13
        (2000 9:00 AM EDT)October 13
    ...
  """
  test "Every Friday the 13th, forever" do
  end

  @doc """
    The first Saturday that follows the first Sunday of the month,
    forever

    DTSTART;TZID=US-Eastern:19970913T090000
    RRULE:FREQ=MONTHLY;BYDAY=SA;BYMONTHDAY=7,8,9,10,11,12,13

    ==> (1997 9:00 AM EDT)September 13;October 11
        (1997 9:00 AM EST)November 8;December 13
        (1998 9:00 AM EST)January 10;February 7;March 7
        (1998 9:00 AM EDT)April 11;May 9;June 13...
    ...
  """
  test "The first Saturday that follows the first Sunday of the month, forever" do
  end

  @doc """
    Every four years, the first Tuesday after a Monday in November,
    forever (U.S. Presidential Election day):

    DTSTART;TZID=US-Eastern:19961105T090000
    RRULE:FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;BYMONTHDAY=2,3,4,
     5,6,7,8

    ==> (1996 9:00 AM EST)November 5
        (2000 9:00 AM EST)November 7
        (2004 9:00 AM EST)November 2
    ...
  """
  test "Every four years, the first Tuesday after a Monday in November, forever (U.S. Presidential Election day)" do
  end

  @doc """
    The 3rd instance into the month of one of Tuesday, Wednesday or
    Thursday, for the next 3 months

    DTSTART;TZID=US-Eastern:19970904T090000
    RRULE:FREQ=MONTHLY;COUNT=3;BYDAY=TU,WE,TH;BYSETPOS=3

    ==> (1997 9:00 AM EDT)September 4;October 7
        (1997 9:00 AM EST)November 6
  """
  test "The 3rd instance into the month of one of Tuesday, Wednesday or Thursday, for the next 3 months" do
  end

  @doc """
    The 2nd to last weekday of the month

    DTSTART;TZID=US-Eastern:19970929T090000
    RRULE:FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2

    ==> (1997 9:00 AM EDT)September 29
        (1997 9:00 AM EST)October 30;November 27;December 30
        (1998 9:00 AM EST)January 29;February 26;March 30
    ...
  """
  test "The 2nd to last weekday of the month" do
  end

  @doc """
    Every 3 hours from 9:00 AM to 5:00 PM on a specific day

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=HOURLY;INTERVAL=3;UNTIL=19970902T170000Z

    ==> (September 2, 1997 EDT)09:00,12:00,15:00
  """
  test "Every 3 hours from 9:00 AM to 5:00 PM on a specific day" do
  end

  @doc """
    Every 15 minutes for 6 occurrences

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=MINUTELY;INTERVAL=15;COUNT=6

    ==> (September 2, 1997 EDT)09:00,09:15,09:30,09:45,10:00,10:15
  """
  test "Every 15 minutes for 6 occurrences" do
  end

  @doc """
    Every hour and a half for 4 occurrences

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=MINUTELY;INTERVAL=90;COUNT=4

    ==> (September 2, 1997 EDT)09:00,10:30;12:00;13:30
  """
  test "Every hour and a half for 4 occurrences" do
  end

  @doc """
    Every 20 minutes from 9:00 AM to 4:40 PM every day

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=DAILY;BYHOUR=9,10,11,12,13,14,15,16;BYMINUTE=0,20,40
    or
    RRULE:FREQ=MINUTELY;INTERVAL=20;BYHOUR=9,10,11,12,13,14,15,16

    ==> (September 2, 1997 EDT)9:00,9:20,9:40,10:00,10:20,
                               ... 16:00,16:20,16:40
        (September 3, 1997 EDT)9:00,9:20,9:40,10:00,10:20,
                              ...16:00,16:20,16:40
    ...
  """
  test "Every 20 minutes from 9:00 AM to 4:40 PM every day" do
  end


  @doc """
    An example where the days generated makes a difference because of WKST

    DTSTART;TZID=US-Eastern:19970805T090000
    RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=MO

    ==> (1997 EDT)Aug 5,10,19,24

    changing only WKST from MO to SU, yields different results...

    DTSTART;TZID=US-Eastern:19970805T090000
    RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=SU
    ==> (1997 EDT)August 5,17,19,31
  """
  test "An example where the days generated makes a difference because of WKST" do
  end

  def date_expand(date_list) when is_list(date_list) do
    Enum.flat_map(date_list, &date_expand/1)
  end
  def date_expand({year, months, days}) when not is_list(year) do
    date_expand({[year], months, days})
  end
  def date_expand({years, month, days}) when not is_list(month) do
    date_expand({years, [month], days})
  end
  def date_expand({years, months, day}) when not is_list(day) do
    date_expand({years, months, [day]})
  end

  def date_expand({years, months, days}) when
                  is_list(years) and is_list(months) and is_list(days)
  do
    for year <- years,
        month <- months,
        day <- days,
    do: Date.from_erl!({year, month, day})
  end
end
