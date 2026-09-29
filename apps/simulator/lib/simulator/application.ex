defmodule Simulator.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        {Registry, keys: :unique, name: Simulator.Registry},
        {DynamicSupervisor, name: Simulator.Simulations.Supervisor, strategy: :one_for_one}
      ]

    opts = [strategy: :one_for_one, name: Simulator.Supervisor]
    {:ok, _} = Supervisor.start_link(children, opts)
  end
end
