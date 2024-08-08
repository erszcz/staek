defmodule Staek.Repo do
  use Ecto.Repo,
    otp_app: :staek,
    adapter: Ecto.Adapters.SQLite3

  @doc """
  Make a table (a _relation_ in SQL) a Conflict-free Replicated Relation.

  This prepares a table to be synchronised across SQLite instances.
  """
  def enable_crr!(table) when is_binary(table) or is_atom(table) do
    query!("select crsql_as_crr($1);", [table])
  end
end
