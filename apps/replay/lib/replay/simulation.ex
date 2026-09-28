defmodule Replay.Simulation do
  @moduledoc """
  A persisted simulation run.
  """

  use Ecto.Schema

  schema "simulations" do
    field :grid_x, :integer
    field :grid_y, :integer
    field :num_robots, :integer
    field :firestation_coordinate_x, :integer
    field :firestation_coordinate_y, :integer

    has_many :robot_telemetry, Replay.RobotTelemetry

    timestamps(type: :utc_datetime)
  end

  def from_config(%{
        num_robots: num_robots,
        grid_size: {grid_x, grid_y},
        firestation_coordinates: {fcx, fcy}
      }) do
    %__MODULE__{
      num_robots: num_robots,
      grid_x: grid_x,
      grid_y: grid_y,
      firestation_coordinate_x: fcx,
      firestation_coordinate_y: fcy
    }
  end
end
