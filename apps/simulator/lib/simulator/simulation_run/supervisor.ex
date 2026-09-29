defmodule Simulator.SimulationRun.Supervisor do
  @moduledoc """
  A supervisor managing a single simulation.
  """
  use Supervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config, name: __MODULE__)
  end

  @doc """
  Start the simulation.
  """
  def run(run_until, simulation) do
    GenServer.call(
      Simulator.DES,
      {:run_simulation, [run_until: run_until, simulation: simulation]}
    )
  end

  @impl true
  def init(config) do
    children =
      [
        # The discrete event simulation has to be started first, as all others refer to it by name
        Simulator.DES,
        {Simulator.Grid, [size: config.grid_size]},
        Simulator.Firebug,
        {Simulator.FireStation, [config.firestation_coordinates]}
      ] ++
        robot_childspecs(config.num_robots)

    # We tear down everything on failure.
    Supervisor.init(children, strategy: :one_for_all)
  end

  defp robot_childspecs(num_robots) when num_robots > 0 do
    for i <- 1..num_robots do
      Supervisor.child_spec(Simulator.Robot, id: String.to_atom("robot#{i}"))
    end
  end
end
