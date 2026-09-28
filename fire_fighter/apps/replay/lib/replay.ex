defmodule Replay do
  @moduledoc """
  API to create and access simulations.
  """
  alias Replay.Inserter
  alias Replay.Repo
  alias Replay.RobotTelemetry
  alias Replay.Simulation

  @doc """
  Create and persist a new simulation.
  """
  def create_simulation do
    Repo.insert(%Simulation{})
  end

  @doc """
  Get all persisted simulations.
  """
  def get_simulations do
    Repo.all(Simulation)
  end

  @doc """
  Report incoming robot telemetry.
  """
  def robot_telemetry(telemetry = %{}) do
    RobotTelemetry.changeset(%RobotTelemetry{simulation_id: telemetry.simulation_id}, telemetry)
    |> Inserter.insert_async()
  end
end
