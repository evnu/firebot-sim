defmodule Simulator do
  @moduledoc """
  Fire-fighting simulation command line interface.
  """

  def run do
    firestation_coordinates = {10, 10}

    children = [
      # The discrete event simulation has to be started first, as all others refer to it by name
      Simulator.DES,
      {Simulator.Grid, [size: {50, 50}]},
      Simulator.Firebug,
      {Simulator.FireStation, [firestation_coordinates]},
      Simulator.Robot
    ]

    # We tear down everything on failure.
    opts = [strategy: :one_for_all, name: Simulator.Supervisor]
    {:ok, _} = Supervisor.start_link(children, opts)

    IO.puts("Starting simulation")
    :ok = Simulator.DES.run_simulation(5000)
  end
end
