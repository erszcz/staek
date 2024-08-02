defmodule Staek.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    set_repo(Application.fetch_env!(:staek, :repo))

    children = [
      StaekWeb.Telemetry,
      repo(),
      {DNSCluster, query: Application.get_env(:staek, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Staek.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Staek.Finch},
      # Start a worker by calling: Staek.Worker.start_link(arg)
      # {Staek.Worker, arg},
      # Start to serve requests, typically the last entry
      StaekWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Staek.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StaekWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  @pt_repo {__MODULE__, :repo}

  defp set_repo(repo) do
    :persistent_term.put(@pt_repo, repo)
  end

  @doc """
  Return the Ecto.Repo module to be used across the application.
  """
  def repo do
    :persistent_term.get(@pt_repo)
  end
end
