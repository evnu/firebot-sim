defmodule Simulator.DES.State do
  @moduledoc """
  The state of the discrete event simulation coordinator.

  ## Fields

  * `:run_until` defines for how many simulated seconds the simulation runs at maximum. Defaults to `:infinity`.
  * `:schedule` is the discrete event simulation schedule, which holds future events by timestamp.
  * `:timestamp` is the current time.
  * `:simulation` is the simulation object from the `Replay` application. This is used to mark telemetry sent to `Replay`.
  """

  @enforce_keys [:simulation]

  defstruct run_until: :infinity, schedule: %{}, timestamp: 0, simulation: nil

  @doc """
  Get list of current events.
  """
  def events(%__MODULE__{schedule: schedule, timestamp: timestamp}) do
    schedule[timestamp]
  end

  @doc """
  Schedule new events.
  """
  def merge_events(state = %__MODULE__{}, new_events_by_timestamp) do
    Enum.reduce(new_events_by_timestamp, state, &merge_events1/2)
  end

  defp merge_events1({timestamp, new_events}, state = %__MODULE__{}) do
    schedule = state.schedule

    %{
      state
      | schedule:
          Map.put(
            schedule,
            timestamp,
            (schedule[timestamp] || []) ++ new_events
          )
    }
  end

  @doc """
  Proceed to next possible timestamp.
  """
  def step(state = %__MODULE__{}) do
    state =
      state
      |> clean()
      |> drop_current_events()

    with {new_timestamp, _} <-
           Enum.min_by(state.schedule, fn {ts, _} -> ts end, &<=/2, fn -> :finished end) do
      {:ok, %{state | timestamp: new_timestamp}}
    end
  end

  defp clean(state = %__MODULE__{timestamp: timestamp}) do
    schedule =
      state.schedule
      |> Enum.reject(fn {events_timestamp, _} -> events_timestamp < timestamp end)
      |> Map.new()

    %{state | schedule: schedule}
  end

  defp drop_current_events(state) do
    %{state | schedule: Map.delete(state.schedule, state.timestamp)}
  end
end
