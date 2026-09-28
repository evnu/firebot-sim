defmodule Ui.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    dispatch = [
      {:_,
       [
         {"/socket", Ui.SimulationWsHandler, []},
         {"/slow_replay", Ui.SlowReplayWsHandler, []},
         {:_, Plug.Cowboy.Handler, {Ui.Router, []}}
       ]}
    ]

    children = [
      {Plug.Cowboy, scheme: :http, plug: Ui.Router, options: [port: 4000, dispatch: dispatch]}
    ]

    opts = [strategy: :one_for_one, name: Ui.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
