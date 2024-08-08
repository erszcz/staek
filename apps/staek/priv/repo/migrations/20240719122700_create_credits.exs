defmodule Staek.Repo.Migrations.CreateCredits do
  use Ecto.Migration

  def change do
    create table(:credits, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :amount, :decimal
      add :expense_id, :binary_id
      add :user_id, :id

      timestamps(type: :utc_datetime)
    end

    create index(:credits, [:expense_id])
    create index(:credits, [:user_id])
  end
end
