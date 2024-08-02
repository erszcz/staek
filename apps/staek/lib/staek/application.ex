defmodule Staek.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    set_repo(Application.fetch_env!(:staek, :repo))

    children = [
      repo(),
      {DNSCluster, query: Application.get_env(:staek, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Staek.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Staek.Finch}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Staek.Supervisor)
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
