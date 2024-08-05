defmodule StaekDesktop.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      StaekDesktop.Telemetry,
      # Start a worker by calling: StaekDesktop.Worker.start_link(arg)
      # {StaekDesktop.Worker, arg},
      # Start to serve requests, typically the last entry
      StaekDesktop.Endpoint,
      {Desktop.Window,
       [
         app: :staek_desktop,
         id: StaekDesktopWindow,
         url: &StaekDesktop.Endpoint.url/0
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
    StaekDesktop.Endpoint.config_change(changed, removed)
    :ok
  end
end
