defmodule Staek.Expenses.Group do
  use Ecto.Schema
  import Ecto.Changeset

  alias Staek.Accounts.User
  alias Staek.Expenses.GroupMembers

  schema "groups" do
    field :name, :string

    many_to_many :members, User, join_through: GroupMembers

    timestamps(type: :utc_datetime)
  end

  @required ~w[name]a

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, @required)
    |> maybe_put_members(attrs[:members])
    |> validate_required(@required)
  end

  defp maybe_put_members(group, nil), do: group

  defp maybe_put_members(group, members) do
    put_assoc(group, :members, members)
  end
end
