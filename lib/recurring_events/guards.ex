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
      unquote(freq) == :yearly or
      unquote(freq) == :monthly or
      unquote(freq) == :weekly or
      unquote(freq) == :daily
    end
  end
end
