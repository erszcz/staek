defmodule Staek.Expenses.GroupMembers do
  use Ecto.Schema
  import Ecto.Changeset

  alias Staek.Accounts.User
  alias Staek.Expenses.Group

  @primary_key {:id, Ecto.Nanoid, autogenerate: true}
  schema "group_members" do
    belongs_to :group, Group, type: Ecto.Nanoid
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @required ~w[group_id user_id]a

  @doc false
  def changeset(group_members, attrs) do
    group_members
    |> cast(attrs, @required)
    |> validate_required(@required)
  end
end
