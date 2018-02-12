defmodule RR.IcalRrulTest do
  use ExUnit.Case, async: true
  alias RecurringEvents, as: RR

  @doc """
    Daily for 10 occurrences

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=DAILY;COUNT=10

    ==> (1997 9:00 AM EDT)September 2-11
  """
  test "Daily for 10 occurrences" do
    result =
      ~D[1997-09-02]
      |> RR.unfold(%{freq: :daily, count: 10})

    assert date_expand({1997, 09, 2..11}) == result |> Enum.take(999)
  end

  @doc """
    Daily until December 24, 1997

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=DAILY;UNTIL=19971224T000000Z

    ==> (1997 9:00 AM EDT)September 2-30;October 1-25
        (1997 9:00 AM EST)October 26-31;November 1-30;December 1-23
  """
  test "Daily until December 24, 1997" do
    result =
      ~D[1997-09-02]
      |> RR.unfold(%{freq: :daily, until: ~D[1997-12-24]})

    assert date_expand([
             {1997, 09, 2..30},
             {1997, 10, 1..31},
             {1997, 11, 1..30},
             {1997, 12, 1..23},
             # time is not supported yet, so include last
             {1997, 12, 24}
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
    result =
      ~D[1997-09-02]
      |> RR.unfold(%{freq: :daily, interval: 2})

    expect =
      date_expand([
        {1997, 09, [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30]},
        {1997, 10, [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30]},
        {1997, 11, [1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29]},
        {1997, 12, [1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31]}
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
    result =
      ~D[1997-09-02]
      |> RR.unfold(%{freq: :daily, interval: 10, count: 5})

    expect =
      date_expand([
        {1997, 09, [2, 12, 22]},
        {1997, 10, [2, 12]}
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
    result =
      ~D[1998-01-01]
      |> RR.unfold(%{freq: :daily, until: ~D[2000-01-31], by_month: 1})

    expect =
      date_expand([
        {1998, 1, 1..31},
        {1999, 1, 1..31},
        {2000, 1, 1..31}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
  end

  @doc """
    Every February 29, for 5 years

    DTSTART;TZID=US-Eastern:19960229T090000
    RRULE:FREQ=YEARLY;COUNT=5;

    ==> (1996 9:00 AM EDT)February 29
        (1997 9:00 AM EDT)February 28
        (1998 9:00 AM EDT)February 28
        (1999 9:00 AM EDT)February 28
        (2000 9:00 AM EDT)February 29
  """
  test "Every February 29, for 5 years" do
    result =
      ~D[1996-02-29]
      |> RR.unfold(%{freq: :yearly, count: 5})

    expect =
      date_expand([
        {1996, 2, 29},
        {1997, 2, 28},
        {1998, 2, 28},
        {1999, 2, 28},
        {2000, 2, 29}
      ])

    assert expect == result |> Enum.to_list()
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
      ~D[1997-09-02]
      |> RR.unfold(%{freq: :weekly, count: 10})

    expect =
      date_expand([
        {1997, 9, [2, 9, 16, 23, 30]},
        {1997, 10, [7, 14, 21, 28]},
        {1997, 11, 4}
      ])

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
      ~D[1997-09-02]
      |> RR.unfold(%{freq: :weekly, until: ~D[1997-12-24]})

    expect =
      date_expand([
        {1997, 9, [2, 9, 16, 23, 30]},
        {1997, 10, [7, 14, 21, 28]},
        {1997, 11, [4, 11, 18, 25]},
        {1997, 12, [2, 9, 16, 23]}
      ])

    assert expect == result |> Enum.take(999)
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
      ~D[1997-09-02]
      |> RR.unfold(%{freq: :weekly, interval: 2, week_start: :sunday})

    expect =
      date_expand([
        {1997, 9, [2, 16, 30]},
        {1997, 10, [14, 28]},
        {1997, 11, [11, 25]},
        {1997, 12, [9, 23]},
        {1998, 1, [6, 20]}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
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
    result =
      ~D[1997-09-02]
      |> RR.unfold(%{freq: :weekly, count: 10, week_start: :sunday, by_day: [:tuesday, :thursday]})

    expect =
      date_expand([
        {1997, 9, [2, 4, 9, 11, 16, 18, 23, 25, 30]},
        {1997, 10, 2}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
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
    result =
      ~D[1997-09-02]
      |> RR.unfold(%{
        freq: :weekly,
        interval: 2,
        week_start: :sunday,
        by_day: [:monday, :wednesday, :friday],
        until: ~D[1997-12-24]
      })

    expect =
      date_expand([
        {1997, 9, [2, 3, 5, 15, 17, 19, 29]},
        {1997, 10, [1, 3, 13, 15, 17, 27, 29, 31]},
        {1997, 11, [10, 12, 14, 24, 26, 28]},
        # as we are testing it on dates only
        {1997, 12, [8, 10, 12, 22, 24]}
        # 24th should be included as well
      ])

    assert expect == result |> Enum.take(999)
  end

  @doc """
    Every other week on Tuesday and Thursday, for 8 occurrences

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=8;WKST=SU;BYDAY=TU,TH

    ==> (1997 9:00 AM EDT)September 2,4,16,18,30;October 2,14,16
  """
  test "Every other week on Tuesday and Thursday, for 8 occurrences" do
    result =
      ~D[1997-09-02]
      |> RR.unfold(%{
        freq: :weekly,
        interval: 2,
        week_start: :sunday,
        count: 8,
        by_day: [:tuesday, :thursday]
      })

    expect =
      date_expand([
        {1997, 9, [2, 4, 16, 18, 30]},
        {1997, 10, [2, 14, 16]}
      ])

    assert expect == result |> Enum.take(999)
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
    result =
      ~D[1997-09-05]
      |> RR.unfold(%{
        freq: :monthly,
        count: 10,
        by_day: [{1, :friday}]
      })

    expect =
      date_expand([
        {1997, 9, 5},
        {1997, 10, 3},
        {1997, 11, 7},
        {1997, 12, 5},
        {1998, 1, 2},
        {1998, 2, 6},
        {1998, 3, 6},
        {1998, 4, 3},
        {1998, 5, 1},
        {1998, 6, 5}
      ])

    assert expect == result |> Enum.take(999)
  end

  @doc """
    Monthly on the 1st Friday until December 24, 1997

    DTSTART;TZID=US-Eastern:19970905T090000
    RRULE:FREQ=MONTHLY;UNTIL=19971224T000000Z;BYDAY=1FR

    ==> (1997 9:00 AM EDT)September 5;October 3
        (1997 9:00 AM EST)November 7;December 5
  """
  test "Monthly on the 1st Friday until December 24, 1997" do
    result =
      ~D[1997-09-05]
      |> RR.unfold(%{
        freq: :monthly,
        until: ~D[1997-12-24],
        by_day: [{1, :friday}]
      })

    expect =
      date_expand([
        {1997, 9, 5},
        {1997, 10, 3},
        {1997, 11, 7},
        {1997, 12, 5}
      ])

    assert expect == result |> Enum.take(999)
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
      ~D[1997-09-07]
      |> RR.unfold(%{
        freq: :monthly,
        interval: 2,
        count: 10,
        by_day: [{1, :sunday}, {-1, :sunday}]
      })

    expect =
      date_expand([
        {1997, 9, [7, 28]},
        {1997, 11, [2, 30]},
        {1998, 1, [4, 25]},
        {1998, 3, [1, 29]},
        {1998, 5, [3, 31]}
      ])

    assert expect == result |> Enum.take(999)
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
    result =
      ~D[1997-09-22]
      |> RR.unfold(%{
        freq: :monthly,
        count: 6,
        by_day: {-2, :monday}
      })

    expect =
      date_expand([
        {1997, 9, 22},
        {1997, 10, 20},
        {1997, 11, 17},
        {1997, 12, 22},
        {1998, 1, 19},
        {1998, 2, 16}
      ])

    assert expect == result |> Enum.take(999)
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
    result =
      ~D[1997-09-28]
      |> RR.unfold(%{
        freq: :monthly,
        by_month_day: -3
      })

    expect =
      date_expand([
        {1997, 9, 28},
        {1997, 10, 29},
        {1997, 11, 28},
        {1997, 12, 29},
        {1998, 1, 29},
        {1998, 2, 26}
      ])

    assert expect == result |> Enum.take(6)
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
    result =
      ~D[1997-09-02]
      |> RR.unfold(%{
        freq: :monthly,
        count: 10,
        by_month_day: [2, 15]
      })

    expect =
      date_expand([
        {1997, 9, [2, 15]},
        {1997, 10, [2, 15]},
        {1997, 11, [2, 15]},
        {1997, 12, [2, 15]},
        {1998, 1, [2, 15]}
      ])

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
      ~D[1997-09-30]
      |> RR.unfold(%{
        freq: :monthly,
        count: 10,
        by_month_day: [1, -1]
      })

    expect =
      date_expand([
        {1997, 9, 30},
        {1997, 10, [1, 31]},
        {1997, 11, [1, 30]},
        {1997, 12, [1, 31]},
        {1998, 1, [1, 31]},
        {1998, 2, 1}
      ])

    assert expect == result |> Enum.take(999)
  end

  @doc """
  Every 18 months on the 10th thru 15th of the month for 10
  occurrences:

    DTSTART;TZID=US-Eastern:19970910T090000
    RRULE:FREQ=MONTHLY;INTERVAL=18;COUNT=10;BYMONTHDAY=10,11,12,13,14,
     15

    ==> (1997 9:00 AM EDT)September 10,11,12,13,14,15
        (1999 9:00 AM EST)March 10,11,12,13
  """
  test "Every 18 months on the 10th thru 15th of the month for 10 occurrences" do
    result =
      ~D[1997-09-10]
      |> RR.unfold(%{
        freq: :monthly,
        interval: 18,
        count: 10,
        by_month_day: [10, 11, 12, 13, 14, 15]
      })

    expect =
      date_expand([
        {1997, 9, [10, 11, 12, 13, 14, 15]},
        {1999, 3, [10, 11, 12, 13]}
      ])

    assert expect == result |> Enum.take(999)
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
    result =
      ~D[1997-09-02]
      |> RR.unfold(%{
        freq: :monthly,
        interval: 2,
        by_day: :tuesday
      })

    expect =
      date_expand([
        {1997, 9, [2, 9, 16, 23, 30]},
        {1997, 11, [4, 11, 18, 25]},
        {1998, 1, [6, 13, 20, 27]},
        {1998, 3, [3, 10, 17, 24, 31]}
      ])

    assert expect == result |> Enum.take(18)
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
    result =
      ~D[1997-06-10]
      |> RR.unfold(%{freq: :yearly, count: 10, by_month: [6, 7]})

    expect =
      date_expand([
        {1997..2001, [6, 7], 10}
      ])

    assert expect == result |> Enum.take(999)
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
    result =
      ~D[1997-03-10]
      |> RR.unfold(%{freq: :yearly, count: 10, by_month: [1, 2, 3], interval: 2})

    expect =
      date_expand([
        {1997, 3, 10},
        {1999, [1, 2, 3], 10},
        {2001, [1, 2, 3], 10},
        {2003, [1, 2, 3], 10}
      ])

    assert expect == result |> Enum.take(999)
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
    result =
      ~D[1997-01-01]
      |> RR.unfold(%{
        freq: :yearly,
        count: 10,
        by_year_day: [1, 100, 200],
        interval: 3
      })

    expect =
      date_expand([
        {1997, 1, 1},
        {1997, 4, 10},
        {1997, 7, 19},
        {2000, 1, 1},
        {2000, 4, 9},
        {2000, 7, 18},
        {2003, 1, 1},
        {2003, 4, 10},
        {2003, 7, 19},
        {2006, 1, 1}
      ])

    assert expect == result |> Enum.take(999)
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
    result =
      ~D[1997-05-19]
      |> RR.unfold(%{
        freq: :yearly,
        by_day: {20, :monday}
      })

    expect =
      date_expand([
        {1997, 5, 19},
        {1998, 5, 18},
        {1999, 5, 17}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
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
    result =
      ~D[1997-05-12]
      |> RR.unfold(%{
        freq: :yearly,
        by_week_number: 20,
        by_day: :monday
      })

    expect =
      date_expand([
        {1997, 5, 12},
        {1998, 5, 11},
        {1999, 5, 17}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
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
    result =
      ~D[1997-03-13]
      |> RR.unfold(%{freq: :yearly, by_month: 3, by_day: :thursday})

    expect =
      date_expand([
        {1997, 3, [13, 20, 27]},
        {1998, 3, [5, 12, 19, 26]},
        {1999, 3, [4, 11, 18, 25]}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
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
    result =
      ~D[1997-06-05]
      |> RR.unfold(%{
        freq: :yearly,
        by_month: [6, 7, 8],
        by_day: :thursday
      })

    expect =
      date_expand([
        {1997, 6, [5, 12, 19, 26]},
        {1997, 7, [3, 10, 17, 24, 31]},
        {1997, 8, [7, 14, 21, 28]},
        {1998, 6, [4, 11, 18, 25]},
        {1998, 7, [2, 9, 16, 23, 30]},
        {1998, 8, [6, 13, 20, 27]},
        {1999, 6, [3, 10, 17, 24]},
        {1999, 7, [1, 8, 15, 22, 29]},
        {1999, 8, [5, 12, 19, 26]}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
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
    result =
      ~D[1997-09-02]
      |> RR.unfold(%{
        freq: :monthly,
        by_day: :friday,
        by_month_day: 13,
        exclude_date: ~D[1997-09-02]
      })

    expect =
      date_expand([
        {1998, 2, 13},
        {1998, 3, 13},
        {1998, 11, 13},
        {1999, 8, 13},
        {2000, 10, 13}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
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
    result =
      ~D[1997-09-13]
      |> RR.unfold(%{
        freq: :monthly,
        by_day: :saturday,
        by_month_day: [7, 8, 9, 10, 11, 12, 13]
      })

    expect =
      date_expand([
        {1997, 9, 13},
        {1997, 10, 11},
        {1997, 11, 8},
        {1997, 12, 13},
        {1998, 1, 10},
        {1998, 2, 7},
        {1998, 3, 7},
        {1998, 4, 11},
        {1998, 5, 9},
        {1998, 6, 13}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
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
    result =
      ~D[1996-11-05]
      |> RR.unfold(%{
        freq: :yearly,
        interval: 4,
        by_month: 11,
        by_day: :tuesday,
        by_month_day: [2, 3, 4, 5, 6, 7, 8]
      })

    expect =
      date_expand([
        {1996, 11, 5},
        {2000, 11, 7},
        {2004, 11, 2}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
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
    result =
      ~D[1997-09-04]
      |> RR.unfold(%{
        freq: :monthly,
        count: 3,
        by_day: [:tuesday, :wednesday, :thursday],
        by_set_position: 3
      })

    expect =
      date_expand([
        {1997, 9, 4},
        {1997, 10, 7},
        {1997, 11, 6}
      ])

    assert expect == result |> Enum.take(999)
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
    result =
      ~D[1997-09-29]
      |> RR.unfold(%{
        freq: :monthly,
        by_day: [:monday, :tuesday, :wednesday, :thursday, :friday],
        by_set_position: -2
      })

    expect =
      date_expand([
        {1997, 9, 29},
        {1997, 10, 30},
        {1997, 11, 27},
        {1997, 12, 30},
        {1998, 1, 29},
        {1998, 2, 26},
        {1998, 3, 30}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
  end

  @doc """
    Every 3 hours from 9:00 AM to 5:00 PM on a specific day

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=HOURLY;INTERVAL=3;UNTIL=19970902T170000Z

    ==> (September 2, 1997 EDT)09:00,12:00,15:00
  """
  test "Every 3 hours from 9:00 AM to 5:00 PM on a specific day" do
    result =
      ~N[1997-09-02 09:00:00]
      |> RR.unfold(%{
        freq: :hourly,
        interval: 3,
        until: ~N[1997-09-02 17:00:00]
      })

    expect =
      date_expand([
        {{1997, 9, 2}, {9, 0, 0}},
        {{1997, 9, 2}, {12, 0, 0}},
        {{1997, 9, 2}, {15, 0, 0}}
      ])

    assert expect == result |> Enum.take(999)
  end

  @doc """
    Every 15 minutes for 6 occurrences

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=MINUTELY;INTERVAL=15;COUNT=6

    ==> (September 2, 1997 EDT)09:00,09:15,09:30,09:45,10:00,10:15
  """
  test "Every 15 minutes for 6 occurrences" do
    result =
      ~N[1997-09-02 09:00:00]
      |> RR.unfold(%{
        freq: :minutely,
        interval: 15,
        count: 6
      })

    expect =
      date_expand([
        {{1997, 9, 2}, {9, [0, 15, 30, 45], 0}},
        {{1997, 9, 2}, {10, [0, 15], 0}}
      ])

    assert expect == result |> Enum.take(999)
  end

  @doc """
    Every hour and a half for 4 occurrences

    DTSTART;TZID=US-Eastern:19970902T090000
    RRULE:FREQ=MINUTELY;INTERVAL=90;COUNT=4

    ==> (September 2, 1997 EDT)09:00,10:30;12:00;13:30
  """
  test "Every hour and a half for 4 occurrences" do
    result =
      ~N[1997-09-02 09:00:00]
      |> RR.unfold(%{
        freq: :minutely,
        interval: 90,
        count: 4
      })

    expect =
      date_expand([
        {{1997, 9, 2}, {9, 0, 0}},
        {{1997, 9, 2}, {10, 30, 0}},
        {{1997, 9, 2}, {12, 0, 0}},
        {{1997, 9, 2}, {13, 30, 0}}
      ])

    assert expect == result |> Enum.take(999)
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
    result =
      ~N[1997-09-02 09:00:00]
      |> RR.unfold(%{
        freq: :daily,
        by_hour: [9, 10, 11, 12, 13, 14, 15, 16],
        by_minute: [0, 20, 40]
      })

    expect =
      date_expand([
        {{1997, 9, [2, 3]}, {[9, 10, 11, 12, 13, 14, 15, 16], [0, 20, 40], 0}}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
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
    rules = %{
      freq: :weekly,
      interval: 2,
      count: 4,
      by_day: [:tuesday, :sunday],
      week_start: :monday
    }

    monday_result =
      ~D[1997-08-05]
      |> RR.unfold(rules)

    monday_expect =
      date_expand([
        {1997, 8, [5, 10, 19, 24]}
      ])

    sunday_result =
      ~D[1997-08-05]
      |> RR.unfold(%{rules | week_start: :sunday})

    sunday_expect =
      date_expand([
        {1997, 8, [5, 17, 19, 31]}
      ])

    refute monday_result == sunday_result
    assert monday_expect == monday_result |> Enum.take(monday_expect |> Enum.count())
    assert sunday_expect == sunday_result |> Enum.take(sunday_expect |> Enum.count())
  end

  # additional tests
  test "for 4th and last monday in each year forever" do
    result =
      ~D[2018-01-01]
      |> RR.unfold(%{
        freq: :yearly,
        by_day: :monday,
        by_set_position: [4, -1],
        exclude_date: ~D[2018-01-01]
      })

    expect =
      date_expand([
        {2018, 1, 22},
        {2018, 12, 31},
        {2019, 1, 28},
        {2019, 12, 30},
        {2020, 1, 27},
        {2020, 12, 28},
        {2021, 1, 25},
        {2021, 12, 27},
        {2022, 1, 24},
        {2022, 12, 26}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
  end

  test "Test weekly frequency with by_set_position" do
    result =
      ~N[2018-01-01 09:00:00]
      |> RR.unfold(%{
        freq: :weekly,
        by_hour: [1, 2, 3, 4, 5],
        by_set_position: [2, 4],
        week_start: :tuesday,
        exclude_date: ~N[2018-01-01 09:00:00]
      })

    expect =
      date_expand([
        {{2018, 1, 8}, {2, 0, 0}},
        {{2018, 1, 8}, {4, 0, 0}},
        {{2018, 1, 15}, {2, 0, 0}},
        {{2018, 1, 15}, {4, 0, 0}},
        {{2018, 1, 22}, {2, 0, 0}},
        {{2018, 1, 22}, {4, 0, 0}},
        {{2018, 1, 29}, {2, 0, 0}},
        {{2018, 1, 29}, {4, 0, 0}},
        {{2018, 2, 5}, {2, 0, 0}},
        {{2018, 2, 5}, {4, 0, 0}}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
  end

  test "Test daily frequency with by_set_position" do
    result =
      ~N[2018-01-01 00:00:00]
      |> RR.unfold(%{
        freq: :daily,
        by_hour: [1, 2, 3, 4, 5],
        by_set_position: [2, 4],
        exclude_date: ~N[2018-01-01 00:00:00]
      })

    expect =
      date_expand([
        {{2018, 1, 1}, {2, 0, 0}},
        {{2018, 1, 1}, {4, 0, 0}},
        {{2018, 1, 2}, {2, 0, 0}},
        {{2018, 1, 2}, {4, 0, 0}},
        {{2018, 1, 3}, {2, 0, 0}},
        {{2018, 1, 3}, {4, 0, 0}},
        {{2018, 1, 4}, {2, 0, 0}},
        {{2018, 1, 4}, {4, 0, 0}},
        {{2018, 1, 5}, {2, 0, 0}},
        {{2018, 1, 5}, {4, 0, 0}}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
  end

  test "1st, 2nd and 3rd week when week starts at wednesday" do
    result =
      ~D[2018-01-01]
      |> RR.unfold(%{
        week_start: :wednesday,
        freq: :weekly,
        by_week_number: [2, 3, 4]
      })

    expect =
      date_expand([
        {2018, 1, [1, 15, 22, 29]}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
  end

  test "1st, 2nd and 3rd week when yearly will expand to whole weeks" do
    result =
      ~D[2018-01-01]
      |> RR.unfold(%{
        freq: :yearly,
        by_week_number: [2, 3, 4]
      })

    expect =
      date_expand([
        {2018, 1, 1},
        {2018, 1, 8..28},
        {2019, 1, 7..27}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
  end

  test "By every 15 seconds forever (oh yeah)" do
    result =
      ~N[2018-01-01 09:00:00]
      |> RR.unfold(%{
        freq: :secondly,
        by_second: [0, 15, 30, 45]
      })

    expect =
      date_expand([
        {{2018, 1, 1}, {9, 0..2, [0, 15, 30, 45]}}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
  end

  test "0, 15, 30, 45 sec after each hour forever" do
    result =
      ~N[2018-01-01 09:00:00]
      |> RR.unfold(%{
        freq: :hourly,
        by_second: [0, 15, 30, 45]
      })

    expect =
      date_expand([
        {{2018, 1, 1}, {9..11, 0, [0, 15, 30, 45]}}
      ])

    assert expect == result |> Enum.take(expect |> Enum.count())
  end

  describe "count shoud be resolbed after exclude dates" do
    test "when freq: :daily" do
      result =
        RR.take(
          %{
            date_start: ~D[2018-01-01],
            exclude_date: ~D[2018-01-01],
            freq: :daily,
            count: 1
          },
          99
        )

      assert [~D[2018-01-02]] == result
    end

    test "when freq: :weekly" do
      result =
        RR.take(
          %{
            date_start: ~D[2018-01-01],
            exclude_date: ~D[2018-01-01],
            freq: :weekly,
            count: 1
          },
          99
        )

      assert [~D[2018-01-08]] == result
    end

    test "when freq: :monthly" do
      result =
        RR.take(
          %{
            date_start: ~D[2018-01-01],
            exclude_date: ~D[2018-01-01],
            freq: :monthly,
            count: 1
          },
          99
        )

      assert [~D[2018-02-01]] == result
    end

    test "when freq: :yearly" do
      result =
        RR.take(
          %{
            date_start: ~D[2018-01-01],
            exclude_date: ~D[2018-01-01],
            freq: :yearly,
            count: 1
          },
          99
        )

      assert [~D[2019-01-01]] == result
    end
  end

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
