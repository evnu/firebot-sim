defmodule Simulator.Robot.State do
  @moduledoc """
  A robots state.

  ## Fields

  * `:firestation_coordinates` are the stored coordinates of the fire station that the robot belongs to.
  * `:coordinates` are the robots current coordinates
  * `:action` defines what the robot is currently doing. It can be
    * `:waiting`
    * `{:move_to, coordinates}` when it moves somewhere
    * `{:extinguishing, coordinates}` if it reached a fire and extinguishes it
    * `:out_of_power` if this thing is dead.
  """
  @enforce_keys [:firestation_coordinates, :coordinates]

  defstruct [:firestation_coordinates, :coordinates, action: :waiting, soc: 100]

  def reset(state = %__MODULE__{}) do
    state
  end

  def available?(state = %__MODULE__{}) do
    state.firestation_coordinates == state.coordinates &&
      state.soc > 0 &&
      state.action == :waiting
  end

  def discharge(state = %__MODULE__{}) do
    %{state | soc: max(0, state.soc - 0.5)}
  end

  def charge(state = %__MODULE__{}) do
    %{state | soc: min(100, state.soc + 1)}
  end

  def discharged(state = %__MODULE__{}) do
    %{state | action: :out_of_power}
  end

  def return_home(state = %__MODULE__{}) do
    %{state | action: {:move_to, state.firestation_coordinates}}
  end

  def one_step_to(state = %__MODULE__{}, {x2, y2}) do
    {x1, y1} = state.coordinates

    new_coords =
      if x1 != x2 do
        {sig(x2 - x1) + x1, y1}
      else
        {x1, sig(y2 - y1) + y1}
      end

    %{state | coordinates: new_coords}
  end

  defp sig(n) when n < 0, do: -1
  defp sig(n) when n > 0, do: +1
  defp sig(_), do: 0
end
