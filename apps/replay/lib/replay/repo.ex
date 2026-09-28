defmodule Replay.Repo do
  use Ecto.Repo,
    otp_app: :replay,
    adapter: Ecto.Adapters.Postgres
end
