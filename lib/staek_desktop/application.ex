defmodule StaekDesktop.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      StaekWeb.Telemetry,
      Staek.repo(),
      {Ecto.Migrator,
       repos: Application.fetch_env!(:staek_desktop, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:staek_desktop, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: StaekDesktop.PubSub},
      # Start a worker by calling: StaekDesktop.Worker.start_link(arg)
      # {StaekDesktop.Worker, arg},
      # Start to serve requests, typically the last entry
      StaekWeb.Endpoint,
      {Desktop.Window,
       [
         app: :staek_desktop,
         id: StaekDesktopWindow,
         url: &StaekWeb.Endpoint.url/0
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StaekDesktop.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StaekWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end