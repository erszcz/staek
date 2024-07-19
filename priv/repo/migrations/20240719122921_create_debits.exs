defmodule Staek.Repo.Migrations.CreateDebits do
  use Ecto.Migration

  def change do
    create table(:debits) do
      add :amount, :decimal
      add :expense_id, references(:expenses, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:debits, [:expense_id])
    create index(:debits, [:user_id])
  end
end
