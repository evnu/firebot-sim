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
      <head><title>Simulation Runner</title></head>
      <body>
        <h1>Run a Simulation</h1>
        <button id="start">Start Simulation</button>
        <div id="log">Connecting...</div>

        <h3>Message Log</h3>
        <table>
          <thead>
            <tr>
              <th>Timestamp</th>
              <th>Sender</th>
              <th>Message</th>
            </tr>
          </thead>
          <tbody id="eventsTable">
            <!-- Dynamic rows will be inserted here -->
          </tbody>
        </table>

        <script>
          const logDiv = document.getElementById('log');
          const eventsTable = document.getElementById('eventsTable');
          const startBtn = document.getElementById('start');
          const ws = new WebSocket("ws://localhost:4000/socket");

          ws.onmessage = function(event) {
            try {
              const data = JSON.parse(event.data);
              const row = document.createElement('tr');
              row.innerHTML = `
                <td>${data.timestamp}</td>
                <td><strong>${data.sender}</strong></td>
                <td>${data.message}</td>
              `;
              eventsTable.appendChild(row);
            } catch(e) {
              console.log(e)
              logDiv.innerHTML += "<br>" + event.data;
            }
          };

          ws.onopen = function() {
            logDiv.innerHTML = "Connected to Elixir WebSocket!";
          };

          startBtn.onclick = () => {
            eventsTable.innerHTML = '';
            log.innerHTML = '';
            ws.send("runSimulation");
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
