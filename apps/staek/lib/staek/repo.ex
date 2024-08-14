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

  def get_crsql_changes!(since_db_version \\ 0) do
    q = """
    SELECT "table", "pk", "cid", "val", "col_version", "db_version", "site_id", "cl", "seq"
    FROM crsql_changes
    WHERE db_version > $1
    """

    args = [since_db_version]
    result = query!(q, args)
    changes_to_entries(result)
  end

  def get_crsql_changes_for_site!(site_id, since_db_version \\ 0) do
    q = """
    SELECT "table", "pk", "cid", "val", "col_version", "db_version", COALESCE("site_id", crsql_site_id()), "cl", "seq"
    FROM crsql_changes
    WHERE db_version > $1 AND site_id IS NOT $2
    """

    args = [since_db_version, site_id]
    result = query!(q, args)
    changes_to_entries(result)
  end

  def apply_crsql_changes(entries) do
    insert_all("crsql_changes", entries)
  end

  def get_crsql_db_version(db_version \\ 0) do
    q =
      "SELECT db_version FROM crsql_changes WHERE db_version >= $1 ORDER BY db_version DESC LIMIT 1;"

    case query!(q, [db_version]) do
      %Exqlite.Result{rows: [[version]]} -> version
      _ -> 0
    end
  end

  defp changes_to_entries(changes_result) do
    Enum.map(changes_result.rows, &Enum.zip(changes_result.columns, &1))
  end
end
