defmodule Ui.WsHandler do
  @behaviour :cowboy_websocket

  # 1. Upgrade the HTTP request to a WebSocket connection
  @impl true
  def init(req, _state) do
    {:cowboy_websocket, req, %{}, %{idle_timeout: :infinity}}
  end

  # 2. Called when the WebSocket connection is successfully opened
  @impl true
  def websocket_init(state) do
    # Periodically send a message to this process every 2 seconds to simulate data streaming
    timer_ref = :erlang.send_after(2000, self(), :send_tick)
    {:ok, Map.put(state, :timer_ref, timer_ref)}
  end

  # 3. Handle messages sent from Elixir (like our periodic timer or broadcasts)
  @impl true
  def websocket_info(:send_tick, state) do
    # Reschedule the next tick
    timer_ref = :erlang.send_after(2000, self(), :send_tick)

    # Current server time to stream to the client
    payload = "Current Server Time: #{DateTime.utc_now()}"

    # Return {:reply, {:text, "message"}, state} to push data to the browser
    {:reply, {:text, payload}, Map.put(state, :timer_ref, timer_ref)}
  end

  @impl true
  def websocket_info(_info, state), do: {:ok, state}

  # 4. Handle incoming messages sent *from* the browser (optional)
  @impl true
  def websocket_handle({:text, msg}, state) do
    {:reply, {:text, "Echo from server: #{msg}"}, state}
  end
end
