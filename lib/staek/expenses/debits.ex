defmodule Staek.Expenses.Debits do
  use Ecto.Schema
  import Ecto.Changeset

  schema "debits" do
    field :amount, :decimal
    field :expense_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(debits, attrs) do
    debits
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
  end
end
