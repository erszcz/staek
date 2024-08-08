defmodule Staek.Repo.Migrations.CreateExpenses do
  use Ecto.Migration

  def change do
    create table(:expenses, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :name, :string
      add :group_id, :binary_id

      timestamps(type: :utc_datetime)
    end

    create index(:expenses, [:group_id])
  end
end
