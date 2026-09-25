defmodule Simulator.Firebug do
  # FIXME maybe allow seeding the RNG :)
  use GenServer

  alias Simulator.Grid
  alias Simulator.Fire

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def reset do
    GenServer.call(__MODULE__, :reset)
  end

  @impl true
  def init(_) do
    {:ok, []}
  end

  @impl true
  def handle_call(:reset, _, _state) do
    {:reply, :ok, []}
  end

  def handle_call({:schedule_first_fire, timestamp, []}, _, state) do
    first_fire_timestamp = pick_next_fire(timestamp)
    IO.puts("#{timestamp} #{__MODULE__} Scheduling first fire to be at #{first_fire_timestamp}")
    {:reply, {:events, [{first_fire_timestamp, {__MODULE__, :fire, []}}]}, state}
  end

  def handle_call({:fire, timestamp, []}, _, state) do
    IO.puts("#{timestamp} #{__MODULE__} starts fire")

    fire = random_fire(state, timestamp)

    events = [
      {timestamp + 1, {Simulator.Grid, :mark_fire, [fire]}},
      {timestamp + 1, {Simulator.FireStation, :fire_detected, [fire]}},
      {pick_next_fire(timestamp), {__MODULE__, :fire, []}}
    ]

    {:reply, {:events, events}, state}
  end

  defp pick_next_fire(timestamp) do
    # FIXME do something cooler with random. Some proper arrival time. Also, needs a seed from the state.
    timestamp + :rand.uniform(2000)
  end

  defp random_fire(_state, timestamp) do
    {max_x, max_y} = Grid.size()

    %Fire{
      coordinates: {:rand.uniform(max_x), :rand.uniform(max_y)},
      started_at: timestamp,
      burns_until: timestamp + :rand.uniform(1000),
      extinguished_within: :rand.uniform(50),
      # FIXME would be cool to require a larger number of fire fighters as well
      required_fire_fighters: 1
    }
  end
end
