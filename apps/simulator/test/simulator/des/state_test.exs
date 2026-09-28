defmodule StateTest do
  use ExUnit.Case

  alias Simulator.DES.State

  test "merge events" do
    assert State.merge_events(%State{}, %{1 => [:a, :b, :c]}) ==
             %State{schedule: %{1 => [:a, :b, :c]}}

    assert State.merge_events(%State{schedule: %{1 => [:x]}}, %{1 => [:a]}) ==
             %State{schedule: %{1 => [:x, :a]}}
  end

  test "step" do
    assert {:ok, %State{timestamp: 1, schedule: %{1 => []}}} ==
             State.step(%State{timestamp: 0, schedule: %{1 => []}})

    # Ensure progress is made
    assert {:ok, %State{timestamp: 1, schedule: %{1 => []}}} ==
             State.step(%State{timestamp: 0, schedule: %{0 => [], 1 => []}})

    assert :finished == State.step(%State{})
  end
end
