defmodule RecurringEvents.Guards do

  defmacro __using__(_) do
    quote do
      import RecurringEvents.Guards
    end
  end

  defmacro is_freq_valid(freq) do
    quote do
      unquote(freq) == :yearly or
      unquote(freq) == :monthly or
      unquote(freq) == :daily
    end
  end
end
