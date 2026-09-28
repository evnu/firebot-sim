defmodule Simulator.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    config = Simulator.Config.get()

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
    opts = [strategy: :one_for_all, name: Simulator.Supervisor]
    {:ok, _} = Supervisor.start_link(children, opts)
  end

  defp robot_childspecs(num_robots) when num_robots > 0 do
    for i <- 1..num_robots do
      Supervisor.child_spec(Simulator.Robot, id: String.to_atom("robot#{i}"))
    end
  end
end
