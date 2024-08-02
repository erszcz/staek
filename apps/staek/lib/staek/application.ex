defmodule Staek.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Staek.Repo,
      {DNSCluster, query: Application.get_env(:staek, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Staek.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Staek.Finch}
      # Start a worker by calling: Staek.Worker.start_link(arg)
      # {Staek.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Staek.Supervisor)
  end
end
