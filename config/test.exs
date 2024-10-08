import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :staek, Staek.Repo,
  database: Path.expand("../staek_test.db", __DIR__),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :staek_desktop, StaekDesktop.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "FkC/smJJp9jCfVKDx8w8AUd6fT7v39uHJUzH3WEH0W9D5+npp+oh+aDBr3+xe/Y7",
  server: false

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :staek_desktop, StaekDesktop.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "piX2mVtRIfW2aryXdD6AlWeLTd/8o+V1tNQh6I8eCueNpIF7bHEjxpQ7iOvQ/Fos",
  server: false

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :staek, Staek.Repo,
  username: "staek_db",
  password: "staek_db_secret",
  hostname: "localhost",
  database: "staek_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :staek_web, StaekWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "QNlG/Saz+NhncqNrPCF+PehcMsCIIywiZlB9bD19z0NnsF0GLywPCgOmROZ6kUsO",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# In test we don't send emails
config :staek, Staek.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
