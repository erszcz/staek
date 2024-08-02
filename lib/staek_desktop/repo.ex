defmodule StaekDesktop.Repo do
  use Ecto.Repo,
    otp_app: :staek_desktop,
    adapter: Ecto.Adapters.SQLite3
end
