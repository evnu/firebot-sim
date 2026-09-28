defmodule Replay.Repo.Migrations.AddRobotTelemetryTable do
  use Ecto.Migration

  def change do
    create table(:robot_telemetry) do
      add :timestamp, :integer
      add :simulation_id, references(:simulations)
      add :robot_id, :string
      add :soc, :float
      add :coordinate_x, :integer
      add :coordinate_y, :integer
      add :action, :string

      timestamps()
    end
  end
end
