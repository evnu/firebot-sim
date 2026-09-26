defmodule Replay.Simulation do
  @moduledoc """
  A persisted simulation run.
  """

  use Ecto.Schema

  schema "simulations" do
    timestamps(type: :utc_datetime)
  end
end
