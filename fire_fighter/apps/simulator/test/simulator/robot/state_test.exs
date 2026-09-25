defmodule Simulator.Robot.StateTest do
  use ExUnit.Case

  alias Simulator.Robot.State

  test "one_step_to/2" do
    assert %State{firestation_coordinates: {0, 0}, coordinates: {1, 1}} ==
             State.one_step_to(
               %State{
                 firestation_coordinates: {0, 0},
                 coordinates: {0, 1}
               },
               {1, 1}
             )

    assert %State{firestation_coordinates: {0, 0}, coordinates: {1, 0}} ==
             State.one_step_to(
               %State{
                 firestation_coordinates: {0, 0},
                 coordinates: {1, 1}
               },
               {1, 0}
             )

    assert %State{firestation_coordinates: {0, 0}, coordinates: {9, 10}} ==
             State.one_step_to(
               %State{
                 firestation_coordinates: {0, 0},
                 coordinates: {10, 10}
               },
               {1, 0}
             )

    assert %State{firestation_coordinates: {0, 0}, coordinates: {1, 9}} ==
             State.one_step_to(
               %State{
                 firestation_coordinates: {0, 0},
                 coordinates: {1, 10}
               },
               {1, 0}
             )
  end
end
