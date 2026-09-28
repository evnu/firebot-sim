defmodule Replay.Repo.Migrations.AddSimulationsTable do
  use Ecto.Migration

  def change do
    create table(:simulations) do
      timestamps()
    end
  end
end
