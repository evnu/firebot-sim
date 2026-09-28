defmodule Replay.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Replay.Repo,
      Replay.Inserter
    ]

    opts = [strategy: :one_for_one, name: Replay.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
