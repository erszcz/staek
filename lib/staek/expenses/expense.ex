defmodule Staek.Expenses.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  alias Staek.Expenses.Credit
  alias Staek.Expenses.Debit
  alias Staek.Expenses.Group

  schema "expenses" do
    field :name, :string
    field :total, :decimal
    belongs_to :group, Group
    has_many :credits, Credit
    has_many :debits, Debit

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expense, attrs) do
    expense
    |> cast(attrs, [:name, :total])
    |> maybe_put_group(attrs)
    |> validate_required([:name, :total])
  end

  defp maybe_put_group(expense, attrs) do
    if group = attrs["group"] || attrs[:group] do
      put_assoc(expense, :group, group)
    else
      expense
    end
  end
end
