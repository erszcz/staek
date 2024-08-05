[
  import_deps: [:ecto, :ecto_sql, :phoenix],
  subdirectories: ["apps/*"],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: ["mix.exs", "*.{heex,ex,exs}", "{config,apps,lib,test}/**/*.{heex,ex,exs}", "apps/*/priv/*/seeds.exs"]
]
