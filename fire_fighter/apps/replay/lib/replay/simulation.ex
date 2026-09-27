defmodule Replay.Simulation do
  @moduledoc """
  A persisted simulation run.
  """

  use Ecto.Schema

  # FIXME should also store the simulation arguments (grid size, number of robots, etc)
  schema "simulations" do
    has_many :robot_telemetry, Replay.RobotTelemetry

    timestamps(type: :utc_datetime)
  end
end
