defmodule Replay.RobotTelemetry do
  @moduledoc """
  A persisted and replayable robot telemetry event.
  """

  use Ecto.Schema

  alias Replay.Simulation

  schema "robot_telemetry" do
    field :timestamp, :integer
    field :robot_id, :string
    field :soc, :float
    field :coordinate_x, :integer
    field :coordinate_y, :integer
    field :action, :string

    belongs_to :simulation, Simulation

    timestamps(type: :utc_datetime)
  end

  def changeset(robot_telemetry, params = %{}) do
    robot_telemetry
    |> Ecto.Changeset.cast(params, [
      :timestamp,
      :robot_id,
      :soc,
      :coordinate_x,
      :coordinate_y,
      :action
    ])
  end
end
