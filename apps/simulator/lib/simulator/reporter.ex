defmodule Simulator.Reporter do
  @moduledoc """
  Forward messages to a remote reporter and stdout.
  """

  @doc """
  Forward a simulation event.
  """
  def report(timestamp, sender, message) do
    if Process.whereis(SimulationReporter) do
      send(SimulationReporter,
        report: %{timestamp: timestamp, sender: inspect(sender), message: message}
      )
    end

    IO.puts("#{timestamp} #{sender} #{message}")
  end
end
