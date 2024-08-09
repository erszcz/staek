defmodule Staek.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Staek.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:staek, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:staek, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Staek.PubSub},
      {Staek.SyncService, pubsub: Staek.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Staek.Finch}
      # Start a worker by calling: Staek.Worker.start_link(arg)
      # {Staek.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Staek.Supervisor)
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
