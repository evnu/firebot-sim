defmodule Simulator.Config do
  @moduledoc """
  Hardcoded simulation configuration.
  """

  @doc """
  Get the configuration.
  """
  def get do
    %{
      num_robots: 5,
      grid_size: {100, 100},
      firestation_coordinates: {25, 25}
    }
  end
end
