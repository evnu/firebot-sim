defmodule Simulator.FireStation do
  use GenServer

  alias Simulator.Robot
  alias Simulator.Fire
  alias Simulator.Reporter

  alias Replay.Simulation

  defmodule State do
    @moduledoc """
    State of the fire station.

    ## Fields

    * `:coordinates` indicates where the fire station is on the grid
    * `:robots` stores all robots under control with this station
    """
    defstruct [:coordinates, robots: []]

    def add_robot(state = %__MODULE__{}, robot) when is_pid(robot) do
      %{state | robots: [robot | state.robots]}
    end

    def reset(state = %__MODULE__{}) do
      state
    end
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  Reset the fire station to its original state and set a `simulation`.
  """
  def reset(simulation = %Simulation{}) do
    GenServer.call(__MODULE__, {:reset, simulation})
  end

  @doc """
  Register a robot with the fire station and report the fire station's coordinates.
  """
  def register_robot do
    GenServer.call(__MODULE__, :register_robot)
  end

  @impl true
  def init([coordinates]) do
    {:ok, %State{coordinates: coordinates}}
  end

  @impl true
  def handle_call(:register_robot, {pid, _}, state) do
    {:reply, {:ok, state.coordinates}, State.add_robot(state, pid)}
  end

  def handle_call({:reset, simulation}, _, state = %State{}) do
    for robot <- state.robots do
      :ok = Robot.reset(robot, simulation)
    end

    {:reply, :ok, State.reset(state)}
  end

  def handle_call({:fire_detected, timestamp, [fire = %Fire{}]}, _, state) do
    Reporter.report(timestamp, __MODULE__, "informed of a fire at #{inspect(fire.coordinates)}")

    robots_to_send =
      state.robots
      |> Enum.filter(&Robot.available?/1)
      # Some randomness! :)
      |> Enum.shuffle()
      |> Enum.take(fire.required_fire_fighters)

    # We only send robots if we have a chance of winning.
    events =
      if length(robots_to_send) >= fire.required_fire_fighters do
        Reporter.report(timestamp, __MODULE__, "sends robots")

        for robot <- robots_to_send do
          {:events, events} = Robot.call_for(robot, timestamp, fire)
          events
        end
        |> List.flatten()
      else
        Reporter.report(timestamp, __MODULE__, "cannot send robots")
        []
      end

    {:reply, {:events, events}, state}
  end

  def handle_call({:recall_from_location, timestamp, coordinates}, _, state) do
    Reporter.report(timestamp, __MODULE__, "recalls units from #{inspect(coordinates)}")

    events =
      Enum.flat_map(state.robots, fn robot ->
        {:events, events} = GenServer.call(robot, {:recall_for, timestamp, coordinates})
        events
      end)

    {:reply, {:events, events}, state}
  end
end
