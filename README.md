# FireBot Sim

A fire-fighting autonomous robot simulation, with a simple data-gathering
backend and a frontend to monitor the fleet of robots. See
[excalidraw](https://excalidraw.com/#token=r8vfHol3f7B43MGh6bous) for the
planning of this simulation.

## Run the system (with docker compose)

The supplied Dockerfile is built automatically with docker compose:

```bash
docker compose up
```

Browse to `localhost:4000` for the web-frontend to observe the fleet and start a simulation.

## Run the system locally

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
