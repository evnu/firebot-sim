defmodule Simulator.Config do
  @moduledoc """
  Hardcoded simulation configuration.
  """

  @doc """
  Get the configuration.
  """
  def get do
    %{
      num_robots: 2,
      grid_size: {50, 50},
      firestation_coordinates: {25, 25}
    }
  end
end
