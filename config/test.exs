import Config

# Configure LiveWebServer

config :live_web_server,
  virtual_hosts_dir: System.get_env("VIRTUAL_HOSTS_DIR"),
  admin_host: System.get_env("ADMIN_HOST") || "admin.lvh.me"

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :live_web_server, LiveWebServer.Repo,
  username: "postgres",
  password: "password",
  hostname: "live_web_server-db-1",
  database: "live_web_server_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :live_web_server, LiveWebServerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Omq1m6HLY3kuXJaEF4IqbL+pP6OBiyRjFZCMxY08AUc+p3YFoHxIkhikI3mUCci2",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
