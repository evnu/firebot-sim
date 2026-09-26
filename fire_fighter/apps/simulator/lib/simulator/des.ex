defmodule Simulator.DES do
  @moduledoc """
  The fire-fighting simulation's Discrete Event Simulator.

  The simulator runs one simulation at a time. During that time, it does not handle calls at all.
  """
  use GenServer

  alias Simulator.Grid
  alias Simulator.FireStation
  alias Simulator.Firebug

  alias Simulator.DES.State

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def run_simulation(run_until) do
    GenServer.call(Simulator.DES, {:run_simulation, [run_until: run_until]})
  end

  @impl true
  def init(_) do
    {:ok, nil}
  end

  @impl true
  def handle_call({:run_simulation, args}, reply_to, nil) do
    {:noreply, nil, {:continue, {:init_simulation, reply_to, args}}}
  end

  @impl true
  def handle_continue({:init_simulation, reply_to, args}, _state) do
    :ok = Grid.reset()
    :ok = FireStation.reset()
    :ok = Firebug.reset()

    initial_timestamp = 0

    schedule = %{
      initial_timestamp => [
        {Firebug, :schedule_first_fire, []}
      ]
    }

    :finished =
      simulate(%State{
        timestamp: initial_timestamp,
        schedule: schedule,
        run_until: args[:run_until] || :infinity
      })

    :ok = GenServer.reply(reply_to, :ok)

    {:noreply, nil}
  end

  # The main simulation runner.
  defp simulate(state) do
    events = State.events(state)

    with {:ok, state} <-
           state |> State.merge_events(step(events, state.timestamp)) |> State.step(),
         :continue <- check_continue(state) do
      simulate(state)
    end
  end

  defp step(events, timestamp) do
    Enum.reduce(events, %{}, &step1(&1, &2, timestamp))
  end

  defp step1({callee, function, args}, new_events, timestamp) do
    {:events, events_generated_by_callee} = GenServer.call(callee, {function, timestamp, args})

    Enum.reduce(events_generated_by_callee, new_events, fn {ts, event}, acc ->
      Map.put(acc, ts, (acc[ts] || []) ++ [event])
    end)
  end

  defp check_continue(state) do
    if state.run_until == :infinity || state.timestamp <= state.run_until do
      :continue
    else
      :finished
    end
  end
end
