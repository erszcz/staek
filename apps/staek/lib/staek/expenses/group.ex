defmodule Staek.Expenses.Group do
  use Ecto.Schema
  import Ecto.Changeset

  alias Staek.Accounts.User
  alias Staek.Currencies
  alias Staek.Expenses.Expense
  alias Staek.Expenses.GroupMembers

  require Currencies

  schema "groups" do
    field :name, :string
    field :default_currency, Ecto.Enum, values: Currencies.literal_symbols()

    has_many :expenses, Expense
    many_to_many :members, User, join_through: GroupMembers, on_replace: :mark_as_invalid

    timestamps(type: :utc_datetime)
  end

  @required ~w[name]a

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, @required ++ [:default_currency])
    |> maybe_put_members(attrs)
    |> validate_required(@required)
  end

  defp maybe_put_members(group, attrs) do
    if members = attrs["members"] || attrs[:members] do
      put_assoc(group, :members, members)
    else
      group
    end
  end
end
