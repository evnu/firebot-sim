defmodule Simulator.Robot do
  use GenServer

  alias Simulator.Fire
  alias Simulator.FireStation
  alias Simulator.Grid
  alias Simulator.Robot.State
  alias Simulator.Reporter

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def reset(pid, simulation = %Replay.Simulation{}) do
    GenServer.call(pid, {:reset, simulation})
  end

  @doc """
  Return true if the robot is available for fire fighting.

  A robot is available for fire fighting if
    * it is at the fire station, and
    * it has a state-of-charge above 0, and
    * it is not scheduled already for another fire fighting
  """
  def available?(robot) do
    GenServer.call(robot, :available?)
  end

  @doc """
  Tell the robot that it has been called to respond to a fire.
  """
  def call_for(robot, timestamp, fire) do
    GenServer.call(robot, {:call_for, timestamp, fire})
  end

  @impl true
  def init(_) do
    {:ok, firestation_coordinates} = FireStation.register_robot()

    {:ok,
     %State{
       firestation_coordinates: firestation_coordinates,
       coordinates: firestation_coordinates
     }}
  end

  @impl true
  def handle_call({:reset, simulation}, _, state = %State{}) do
    state = State.reset(state, simulation)
    telemetry(0, state)
    {:reply, :ok, state}
  end

  def handle_call(:available?, _, state = %State{}) do
    {:reply, State.available?(state), state}
  end

  def handle_call({:call_for, timestamp, fire = %Fire{}}, _, state = %State{}) do
    telemetry(timestamp, state)
    report(timestamp, state, "called to respond to fire #{inspect(fire.coordinates)}")

    events = [
      {timestamp + 1, {self(), :move_to, fire.coordinates}}
    ]

    {:reply, {:events, events}, %{state | action: {:move_to, fire.coordinates}}}
  end

  def handle_call(
        {:move_to, timestamp, target_coordinates},
        _,
        state = %State{action: {:move_to, target_coordinates}}
      ) do
    telemetry(timestamp, state)

    if state.coordinates != target_coordinates do
      if state.soc > 0 do
        events = [
          {timestamp + 1, {self(), :move_to, target_coordinates}}
        ]

        {:reply, {:events, events},
         state |> State.one_step_to(target_coordinates) |> State.discharge()}
      else
        report(timestamp, state, "is out of juice")
        {:reply, {:events, []}, State.discharged(state)}
      end
    else
      cond do
        state.coordinates == state.firestation_coordinates ->
          report(timestamp, state, "arrived at fire station")

          events = [
            {timestamp + 1, {self(), :waiting, []}}
          ]

          {:reply, {:events, events}, %{state | action: :waiting}}

        fire = Grid.fire(target_coordinates) ->
          report(timestamp, state, "arrived at fire")

          events = [
            {timestamp + 1, {self(), :extinguishing, target_coordinates}},
            {timestamp + fire.extinguished_within, {self(), :extinguished, target_coordinates}}
          ]

          {:reply, {:events, events}, %{state | action: {:extinguishing, fire.coordinates}}}
      end
    end
  end

  # Ignore this move_to, our target changed in the meantime!
  def handle_call({:move_to, _timestamp, _}, _, state = %State{}) do
    {:reply, {:events, []}, state}
  end

  def handle_call(
        {:recall_for, timestamp, coordinates},
        _,
        state = %State{action: {:move_to, coordinates}}
      ) do
    telemetry(timestamp, state)
    report(timestamp, state, "recalled from responding to #{inspect(coordinates)}")

    events = [
      {timestamp + 1, {self(), :move_to, state.firestation_coordinates}}
    ]

    {:reply, {:events, events}, State.return_home(state)}
  end

  # Old recall, ignore.
  def handle_call({:recall_for, _timestamp, _}, _, state) do
    {:reply, {:events, []}, state}
  end

  # Only charge if we are at the firestation
  def handle_call(
        {:waiting, timestamp, []},
        _,
        state = %State{coordinates: c, firestation_coordinates: c}
      ) do
    telemetry(timestamp, state)

    events = [
      {timestamp + 1, {self(), :waiting, []}}
    ]

    {:reply, {:events, events}, State.charge(state)}
  end

  def handle_call({:waiting, _timestamp, []}, _, state = %State{}) do
    {:reply, {:events, []}, state}
  end

  def handle_call(
        {:extinguishing, timestamp, coordinates},
        _,
        state = %State{action: {:extinguishing, coordinates}}
      ) do
    telemetry(timestamp, state)

    if state.soc > 0 do
      events =
        [
          {timestamp + 1, {self(), :extinguishing, coordinates}}
        ]

      {:reply, {:events, events}, State.discharge(state)}
    else
      {:reply, {:events, []}, %{state | action: :out_of_power}}
    end
  end

  def handle_call({:extinguishing, _, _}, _, state = %State{}) do
    {:reply, {:events, []}, state}
  end

  def handle_call(
        {:extinguished, timestamp, coordinates},
        _,
        state = %State{action: {:extinguishing, coordinates}}
      ) do
    telemetry(timestamp, state)

    events =
      if fire = Grid.fire(coordinates) do
        report(timestamp, state, "extinguished a fire")
        :ok = Grid.extinguished(fire)

        [
          {timestamp + 1, {self(), :move_to, state.firestation_coordinates}},
          {timestamp + 1, {FireStation, :recall_from_location, coordinates}}
        ]
      else
        []
      end

    {:reply, {:events, events}, %{state | action: {:move_to, state.firestation_coordinates}}}
  end

  def handle_call({:extinguished, _timestamp, _coordinates}, _, state = %State{}) do
    {:reply, {:events, []}, state}
  end

  defp report(timestamp, _state, message) do
    Reporter.report(timestamp, "#{__MODULE__}(#{inspect(self())})", message)
  end

  defp telemetry(timestamp, state) do
    {coordinate_x, coordinate_y} = state.coordinates

    Replay.robot_telemetry(%{
      timestamp: timestamp,
      robot_id: inspect(self()),
      soc: state.soc,
      coordinate_x: coordinate_x,
      coordinate_y: coordinate_y,
      action: inspect(state.action),
      simulation_id: state.simulation.id
    })
  end
end
