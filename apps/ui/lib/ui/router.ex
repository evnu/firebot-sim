defmodule Ui.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  # Match GET requests to root
  get "/" do
    body = """
    <ul>
      <li><a href="/simulate">Run simulation</a></li>
      <li><a href="/replay">Replay simulation</a></li>
      <li><a href="/cleanup">Drop simulations</a></li>
    </ul>
    """

    html_content = html_wrapper("Robot Simulation", body)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html_content)
  end

  get "/simulate" do
    config = Simulator.Config.get()

    body = """
    <h2>Simulation Specification</h2>
    <ol>
      <li>Number of robots: #{config.num_robots}</li>
      <li>Grid size: #{inspect(config.grid_size)}</li>
      <li>Firestation coordinations: #{inspect(config.firestation_coordinates)}</li>
    </ol>
    <h2>Control Simulation</h2>
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
        logDiv.innerHTML = "";
      };

      startBtn.onclick = () => {
        eventsTable.innerHTML = '';
        log.innerHTML = '';
        ws.send("runSimulation");
      };
    </script>
    """

    html_content = html_wrapper("Simulation Runner", body)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html_content)
  end

  get "/replay" do
    links =
      Replay.get_simulations()
      |> Enum.map(fn sim ->
        "<li><a href='/replay/#{sim.id}'>#{sim.id}</a>: size = (#{sim.grid_x}, #{sim.grid_y}), #robots = #{sim.num_robots}, firestation at (#{sim.firestation_coordinate_x}, #{sim.firestation_coordinate_y}), inserted_at = #{sim.inserted_at}</li>"
      end)
      |> Enum.join("\n")

    body = """
    <ul>
    #{links}
    </ul>
    """

    html_content = html_wrapper("Simulation Replays", body)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html_content)
  end

  get "/replay/:id" do
    body = """
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
    """

    html_content = html_wrapper("Simulation Replay", body)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html_content)
  end

  get "/cleanup" do
    Replay.delete_simulations!()

    html_content =
      html_wrapper("Simulations Cleaned", "Simulations have been deleted.")

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html_content)
  end

  # Fallback catch-all for 404s
  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp html_wrapper(title, body) do
    """
    <!DOCTYPE html>
    <html>
      <head>
        <title>#{title}</title>
        <link rel="stylesheet" href="https://cdn.simplecss.org/simple.min.css">
      </head>
      <body>
      <header>
        <h1>#{title}</h1>
      </header>
      #{body}
      </body>
    </html>
    """
  end
end
