defmodule RecurringEvents do

  def unfold(_date, %{count: _, until: _}), do:
    {:error, "Can have eathier, count or until"}

  def unfold(_date, %{freq: _}) do
    {:ok, []}
  end

  def unfold(_date, _rrule), do: {:error, "Frequency is missing"}
end
