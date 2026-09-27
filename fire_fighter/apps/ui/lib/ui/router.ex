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
        <a href="/replay">Replay simulation</a>
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

  get "/replay" do
    links =
      Replay.get_simulations()
      |> Enum.map(fn sim ->
        "<li><a href='/replay/#{sim.id}'>#{sim.id}: #{sim.inserted_at}</a></li>"
      end)
      |> Enum.join("\n")

    html_content = """
    <!DOCTYPE html>
    <html>
      <head><title>Simulation Replay</title></head>
      <body>
        <h1>Simulations</h1>
        <ul>
        #{links}
        </ul>
      </body>
    </html>
    """

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html_content)
  end

  get "/replay/:id" do
    html_content = """
    <!DOCTYPE html>
    <html>
      <head><title>Simulation Replay</title></head>
      <body>
        <h1>Replay Simulation #{id}</h1>
        <table>
            <thead>
              <tr>
                  <th>Robot ID</th>
                  <th>SoC</th>
                  <th>Coordinate X</th>
                  <th>Coordinate Y</th>
                  <th>Action</th>
              </tr>
            </thead>
            <tbody id='telemetry'>
            </tbody>
        </table>
            
        <div style="display: flex; height: 300px" id="robotTelemetry; margin-top: 10px">
            <div id="log" style="flex: 1; overflow-y: auto; border: 1px solid #ccc; padding: 10px;">
            Connecting...
            </div>
        </div>
        <script>
          const logDiv = document.getElementById('log');
          const telemetryTable = document.getElementById('telemetry');
          const ws = new WebSocket("ws://localhost:4000/slow_replay");

          ws.onmessage = function(event) {
            logDiv.innerHTML += "<br>" + event.data;
            const telemetry = JSON.parse(event.data);
            const robot = document.getElementById(telemetry.robot_id);
            const formattedTelemetry = `
              <tr id='${telemetry.robot_id}'>
                <td>${telemetry.robot_id}</td>
                <td>${telemetry.soc}</td>
                <td>${telemetry.coordinate_x}</td>
                <td>${telemetry.coordinate_y}</td>
                <td>${telemetry.action}</td>
              </tr>
            `;

            if (!robot) {
              telemetryTable.insertAdjacentHTML('beforeend', formattedTelemetry);
            } else {
              robot.outerHTML = formattedTelemetry;
            }
          };

          ws.onopen = function() {
            logDiv.innerHTML = "Connected to Elixir WebSocket!";
            ws.send("#{id}");
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
