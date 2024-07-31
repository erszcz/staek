defmodule Staek.Repo.Migrations.CreateDebits do
  use Ecto.Migration

  def change do
    create table(:debits) do
      add :amount, :decimal
      add :expense_id, references(:expenses, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:debits, [:expense_id])
    create index(:debits, [:user_id])
  end
end
