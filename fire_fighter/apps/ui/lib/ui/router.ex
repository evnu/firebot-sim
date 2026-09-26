defmodule Ui.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  # Match GET requests to root
  get "/" do
    config = Simulator.Config.get()

    html_content = """
    <!DOCTYPE html>
    <html>
      <head><title>Robot Simulation</title></head>
      <body>
        <h1>Robot Fleet</h1>
        Simulation Specification:
        <ol>
          <li>Number of robots: #{config.num_robots}</li>
          <li>Grid size: #{inspect(config.grid_size)}</li>
          <li>Firestation coordinations: #{inspect(config.firestation_coordinates)}</li>
        </ol>
        <a href="/simulate">Run simulation</a>
      </body>
    </html>
    """

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html_content)
  end

  # Match POST requests (e.g., API endpoint or form submission)
  get "/simulate" do
    html_content = """
    <!DOCTYPE html>
    <html>
      <head><title>Elixir Stream</title></head>
      <body>
        <h1>Live Stream from Elixir</h1>
        <div id="log" style="font-family: monospace; background: #f4f4f4; padding: 10px;">Connecting...</div>

        <script>
          const logDiv = document.getElementById('log');
          const ws = new WebSocket("ws://localhost:4000/socket");

          ws.onmessage = function(event) {
            logDiv.innerHTML += "<br>" + event.data;
          };

          ws.onopen = function() {
            logDiv.innerHTML = "Connected to Elixir WebSocket!";
          };
        </script>
      </body>
    </html>
    """

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html_content)
  end

  # Fallback catch-all for 404s
  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
