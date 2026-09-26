defmodule Ui.WsHandler do
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
  def websocket_handle({:text, "startSimulation"}, state) do
    now = DateTime.utc_now()
    Simulator.DES.run_simulation(5000, false)
    {[{:text, "Starting simulation at #{now}"}], state}
  end
end
