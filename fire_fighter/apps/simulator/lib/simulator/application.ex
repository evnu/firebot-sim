defmodule Simulator.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    firestation_coordinates = {10, 10}

    children = [
      # The discrete event simulation has to be started first, as all others refer to it by name
      Simulator.DES,
      {Simulator.Grid, [size: {50, 50}]},
      Simulator.Firebug,
      {Simulator.FireStation, [firestation_coordinates]},
      Supervisor.child_spec(Simulator.Robot, id: :robot1),
      Supervisor.child_spec(Simulator.Robot, id: :robot2),
    ]

    # We tear down everything on failure.
    opts = [strategy: :one_for_all, name: Simulator.Supervisor]
    {:ok, _} = Supervisor.start_link(children, opts)
  end
end
