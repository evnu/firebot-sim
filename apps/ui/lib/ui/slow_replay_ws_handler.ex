defmodule Ui.SlowReplayWsHandler do
  @behaviour :cowboy_websocket

  @impl true
  def init(req, _state) do
    {:cowboy_websocket, req, %{}, %{idle_timeout: :infinity}}
  end

  @impl true
  def websocket_init(_) do
    :timer.send_interval(250, :tick)
    {:ok, []}
  end

  @impl true
  def websocket_info(:tick, []), do: {:ok, []}

  def websocket_info(:tick, telemetry) do
    # Assume that the current timestamp is the one from the
    # top of the telemetry
    [top | _] = telemetry

    {current, future} =
      Enum.split_while(telemetry, fn t ->
        t.timestamp == top.timestamp
      end)

    commands =
      for telemetry <- current do
        event =
          Map.take(telemetry, [:timestamp, :robot_id, :soc, :coordinate_x, :coordinate_y, :action])

        {:text, :json.encode(event)}
      end

    {commands, future}
  end

  def websocket_info(_info, telemetry), do: {:ok, telemetry}

  @impl true
  def websocket_handle({:text, simulation_id_string}, _state) do
    telemetry =
      Replay.Repo.all(Replay.RobotTelemetry,
        simulation_id: String.to_integer(simulation_id_string)
      )
      |> Enum.sort_by(& &1.timestamp)

    {:ok, telemetry}
  end
end
