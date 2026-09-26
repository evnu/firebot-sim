defmodule Simulator.SecondsCounter do
  @moduledoc """
  A process which only ensures that every second is simulated.

  The process writes a progress report every 5 seconds.
  """
  use GenServer

  alias Simulator.Reporter

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def reset do
    GenServer.call(__MODULE__, :reset)
  end

  @impl true
  def init(_) do
    {:ok, nil}
  end

  @impl true
  def handle_call(:reset, _, _state) do
    {:reply, :ok, nil}
  end

  @impl true
  def handle_call({:one_second_passed, timestamp, []}, _, state) do
    if rem(timestamp, 5) == 0 do
      Reporter.report(
        timestamp,
        __MODULE__,
        "Progress report at #{timestamp}"
      )
    end

    {:reply, {:events, [{timestamp + 1, {__MODULE__, :one_second_passed, []}}]}, state}
  end
end
