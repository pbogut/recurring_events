defmodule RecurringEvents.Guards do
  @moduledoc """
  Provides guard macros for internal use
  """

  defmacro __using__(_) do
    quote do
      import RecurringEvents.Guards
    end
  end

  defmacro is_freq_valid(freq) do
    quote do
      unquote(freq) == :yearly or unquote(freq) == :monthly or unquote(freq) == :weekly or
        unquote(freq) == :daily or unquote(freq) == :hourly or unquote(freq) == :minutely or
        unquote(freq) == :secondly
    end
  end

  defmacro is_time_freq(freq) do
    quote do
      unquote(freq) == :hourly or unquote(freq) == :minutely or unquote(freq) == :secondly
    end
  end

  defmacro is_date_freq(freq) do
    quote do
      unquote(freq) == :yearly or unquote(freq) == :monthly or unquote(freq) == :weekly or
        unquote(freq) == :daily
    end
  end

  defmacro is_time_rule(freq) do
    quote do
      unquote(freq) == :by_hour or unquote(freq) == :by_minute or unquote(freq) == :by_second
    end
  end

  defmacro is_date_rule(freq) do
    quote do
      unquote(freq) == :by_month or unquote(freq) == :by_month_day or
        unquote(freq) == :by_week_number or unquote(freq) == :by_year_day or
        unquote(freq) == :by_day
    end
  end

  defmacro is_date(date) do
    quote do
      Map.has_key?(unquote(date), :year) and Map.has_key?(unquote(date), :month) and
        Map.has_key?(unquote(date), :day)
    end
  end

  defmacro has_time(date) do
    quote do
      Map.has_key?(unquote(date), :hour) and Map.has_key?(unquote(date), :minute) and
        Map.has_key?(unquote(date), :second)
    end
  end

  defmacro has_time_rule(rules) do
    quote do
      Map.has_key?(unquote(rules), :by_hour) or Map.has_key?(unquote(rules), :by_minute) or
        Map.has_key?(unquote(rules), :by_second)
    end
  end
end
