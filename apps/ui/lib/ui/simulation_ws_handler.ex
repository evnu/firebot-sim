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

  def websocket_info({:done, start, done}, state) do
    delta_us = DateTime.diff(done, start, :microsecond)

    {[
       {:text, "Finished simulation at #{done}"},
       {:text, "Simulation took #{delta_us} microseconds"}
     ], state}
  end

  def websocket_info(_info, state), do: {:ok, state}

  @impl true
  def websocket_handle({:text, "runSimulation"}, state) do
    start = DateTime.utc_now()
    this = self()

    spawn(fn ->
      Simulator.run_simulation(5000)
      send(this, {:done, start, DateTime.utc_now()})
    end)

    {[{:text, "Started simulation at #{start}"}], state}
  end
end
