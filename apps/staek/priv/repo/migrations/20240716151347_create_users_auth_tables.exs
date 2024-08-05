defmodule Staek.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    string_t =
      case Ecto.Adapter.lookup_meta(Staek.Repo)[:adapter] do
        Ecto.Adapters.Postgres ->
          execute "CREATE EXTENSION IF NOT EXISTS citext", ""
          :citext

        _ ->
          :string
      end

    create table(:users) do
      add :email, string_t, null: false
      add :name, :string, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])

    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
