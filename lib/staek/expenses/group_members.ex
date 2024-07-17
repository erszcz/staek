defmodule Staek.Expenses.GroupMembers do
  use Ecto.Schema
  import Ecto.Changeset

  schema "group_members" do

    field :group_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group_members, attrs) do
    group_members
    |> cast(attrs, [])
    |> validate_required([])
  end
end
