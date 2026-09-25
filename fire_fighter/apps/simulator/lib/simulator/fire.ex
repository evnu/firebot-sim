defmodule Simulator.Fire do
  @moduledoc """
  Representation of a fire.

  ## Fields

  * `:coordinates` marks where the fire burns
  * `:started_at` is the time when the fire started
  * `:burns_until` defines the timestamp when the location is marked as lost
  * `:extinguished_within` defines how long fighting the fire takes to be extinguished, if fire fighters are on the scene
  * `:required_fire_fighters` defines how many fire fighters need to be deployed
  """

  @enforce_keys [
    :coordinates,
    :started_at,
    :burns_until,
    :extinguished_within,
    :required_fire_fighters
  ]

  defstruct [
    :coordinates,
    :started_at,
    :burns_until,
    :extinguished_within,
    :required_fire_fighters,
    ref: &Kernel.make_ref/0
  ]
end
