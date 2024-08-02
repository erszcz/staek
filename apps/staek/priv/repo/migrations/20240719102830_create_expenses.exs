defmodule Staek.Repo.Migrations.CreateExpenses do
  use Ecto.Migration

  def change do
    create table(:expenses) do
      add :name, :string
      add :group_id, references(:groups, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:expenses, [:group_id])
  end
end
