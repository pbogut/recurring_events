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
end
