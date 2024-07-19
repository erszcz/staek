defmodule Staek.Expenses.Credit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "credits" do
    field :amount, :decimal
    field :expense_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(credits, attrs) do
    credits
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
  end
end
