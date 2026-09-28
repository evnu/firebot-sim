import Config

config :replay, Replay.Repo,
  database: "replay",
  username: "postgres",
  password: "postgres",
  hostname: System.get_env("DB_HOST", "localhost")
