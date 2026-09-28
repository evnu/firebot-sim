#!/usr/bin/env bash

# Create the database
mix ecto.create
# Run the migrations
mix ecto.migrate
# Run the monolith
_build/dev/rel/app/bin/app start
