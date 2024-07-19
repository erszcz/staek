defmodule Staek.Repo.Migrations.CreateCredits do
  use Ecto.Migration

  def change do
    create table(:credits) do
      add :amount, :decimal
      add :expense_id, references(:expenses, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:credits, [:expense_id])
    create index(:credits, [:user_id])
  end
end
