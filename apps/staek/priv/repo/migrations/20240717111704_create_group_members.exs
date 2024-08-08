defmodule Staek.Repo.Migrations.CreateGroupMembers do
  use Ecto.Migration

  def change do
    create table(:group_members, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :group_id, :binary_id
      add :user_id, :binary_id

      timestamps(type: :utc_datetime)
    end

    create index(:group_members, [:group_id])
    create index(:group_members, [:user_id])
  end
end
