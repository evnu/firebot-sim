defmodule Ui.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  # Match GET requests to root
  get "/" do
    html_content = """
    <!DOCTYPE html>
    <html>
      <head><title>Robot Simulation</title></head>
      <body>
        <h1>Robot Simulation</h1>
      </body>
    </html>
    """

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html_content)
  end

  # Match POST requests (e.g., API endpoint or form submission)
  post "/api/action" do
    # Handle data here...
    send_resp(conn, 201, "Action received")
  end

  # Fallback catch-all for 404s
  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
