defmodule Replay.Repo.Migrations.AddSimulationInfo do
  use Ecto.Migration

  def change do
    alter table(:simulations) do
      add :grid_x, :integer
      add :grid_y, :integer
      add :num_robots, :integer
      add :firestation_coordinate_x, :integer
      add :firestation_coordinate_y, :integer
    end
  end
end
