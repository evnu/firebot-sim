import Config

config :logger, level: :info

config :replay, Replay.Repo,
  database: "replay",
  username: "fire",
  password: "fire",
  hostname: "localhost"

config :replay,
  ecto_repos: [Replay.Repo]
