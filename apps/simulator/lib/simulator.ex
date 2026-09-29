defmodule Simulator do
  @moduledoc """
  API to start simulations.
  """
  alias Simulator.Simulations.Supervisor

  def run_simulation(run_until) do
    config = Simulator.Config.get()

    {:ok, sup} =
      DynamicSupervisor.start_child(
        Supervisor,
        {Simulator.SimulationRun.Supervisor, config}
      )

    {:ok, simulation} = Replay.create_simulation(config)

    {:finished, _} = Simulator.SimulationRun.Supervisor.run(run_until, simulation)
    DynamicSupervisor.terminate_child(Supervisor, sup)
  end
end
