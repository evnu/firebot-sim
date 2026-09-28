defmodule Replay.MixProject do
  use Mix.Project

  def project do
    [
      app: :replay,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.20",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Replay.Application, []}
    ]
  end

  defp deps do
    [
      {:ecto, "~>3.14"},
      {:ecto_sql, "~> 3.14"},
      {:postgrex, ">= 0.22.0"}
    ]
  end
end
