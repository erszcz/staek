defmodule Staek.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
