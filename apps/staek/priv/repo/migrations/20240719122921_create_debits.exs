defmodule Staek.Repo.Migrations.CreateDebits do
  use Ecto.Migration

  def change do
    create table(:debits, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :amount, :decimal
      add :expense_id, :binary_id
      add :user_id, :id

      timestamps(type: :utc_datetime)
    end

    create index(:debits, [:expense_id])
    create index(:debits, [:user_id])
  end
end
