import Config

config :logger, level: :info

config :replay,
  ecto_repos: [Replay.Repo]
