# FireFighter

A fire-fighting autonomous robot simulation, with a simple data-gathering
backend and a frontend to monitor the fleet of robots.

## Run the system

```bash
# Get the dependencies
mix deps.get
# Start the database
docker compose up -d
# Create the database
mix ecto.create
# Run the migrations
mix ecto.migrate
# Run the monolith
iex -S mix
```

Browse to `localhost:4000` for the web-frontend to observe the fleet and start a simulation.
