defmodule Staek.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      releases: releases()
    ]
  end

  defp releases do
    [
      web: [
        include_executables_for: [:unix],
        applications: [staek_web: :permanent]
      ],
      desktop: [
        include_executables_for: [:unix],
        applications: [staek_desktop: :permanent]
      ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps/ folder.
  defp deps do
    [
      # Required to run "mix format" on ~H/.heex files from the umbrella root
      # TODO bump on release to {:phoenix_live_view, ">= 0.0.0"},
      {:phoenix_live_view, "~> 1.0.0-rc.1", override: true}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  #
  # Aliases listed here are available only for this project
  # and cannot be accessed from applications inside the apps/ folder.
  defp aliases do
    [
      # run `mix setup` in all child apps
      setup: ["cmd mix setup"],
      reset: [&reset/1],
      start_desktop: [&start(:desktop, &1)],
      start_web: [&start(:web, &1)]
    ]
  end

  defp reset(_args) do
    ~S"""
    RELEASE_NAME=web mix ecto.drop ;
    RELEASE_NAME=desktop mix ecto.drop ;
    RELEASE_NAME=web mix ecto.reset &&
    cp _build/dev/lib/staek/db/staek_web.db _build/dev/lib/staek/db/staek_desktop.db &&
    cp _build/dev/lib/staek/db/staek_web.db-shm _build/dev/lib/staek/db/staek_desktop.db-shm &&
    cp _build/dev/lib/staek/db/staek_web.db-wal _build/dev/lib/staek/db/staek_desktop.db-wal
    """
    |> Mix.shell().cmd()
  end

  defp start(app, _args) when app in [:desktop, :web] do
    Mix.shell().cmd(~s"""
    RELEASE_NAME=#{app} iex --sname #{app} -S mix run --no-start -e '{:ok, _} = Application.ensure_all_started(:staek_#{app})'
    """)
  end
end
