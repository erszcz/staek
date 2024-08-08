defmodule Staek.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
