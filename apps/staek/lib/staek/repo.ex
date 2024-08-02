defmodule Staek.Repo do
  use Ecto.Repo,
    otp_app: :staek,
    adapter: Ecto.Adapters.Postgres
end
