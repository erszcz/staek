defmodule Staek.Expenses.Debit do
  use Ecto.Schema
  import Ecto.Changeset

  alias Staek.Accounts.User
  alias Staek.Expenses.Expense

  schema "debits" do
    field :amount, :decimal
    belongs_to :expense, Expense
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(debits, attrs) do
    debits
    |> cast(attrs, [:amount])
    |> maybe_put_expense(attrs)
    |> maybe_put_user(attrs)
    |> validate_required([:amount])
  end

  defp maybe_put_expense(debit, attrs) do
    if expense = attrs[:expense] || attrs["expense"] do
      put_assoc(debit, :expense, expense)
    else
      debit
    end
  end

  defp maybe_put_user(debit, attrs) do
    if user = attrs[:user] || attrs["user"] do
      put_assoc(debit, :user, user)
    else
      debit
    end
  end
end
