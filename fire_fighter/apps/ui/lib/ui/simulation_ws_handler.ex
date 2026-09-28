defmodule Ui.SimulationWsHandler do
  @behaviour :cowboy_websocket

  @impl true
  def init(req, _state) do
    {:cowboy_websocket, req, %{}, %{idle_timeout: :infinity}}
  end

  @impl true
  def websocket_init(state) do
    Process.register(self(), SimulationReporter)
    {:ok, state}
  end

  @impl true
  def websocket_info([report: report], state) do
    {[{:text, :json.encode(report)}], state}
  end

  def websocket_info(_info, state), do: {:ok, state}

  @impl true
  def websocket_handle({:text, "runSimulation"}, state) do
    start = DateTime.utc_now()
    spawn(fn -> Simulator.DES.run_simulation(5000) end)
    done = DateTime.utc_now()
    delta_us = DateTime.diff(done, start, :microsecond)

    {[
       {:text, "Started simulation at #{start}"},
       {:text, "Finished simulation at #{done}"},
       {:text, "Simulation took #{delta_us} microseconds"}
     ], state}
  end
end
