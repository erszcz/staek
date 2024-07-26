defmodule Staek.Expenses.Credit do
  use Ecto.Schema
  import Ecto.Changeset

  alias Staek.Accounts.User
  alias Staek.Expenses.Expense

  schema "credits" do
    field :amount, :decimal
    belongs_to :expense, Expense
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(credit, attrs) do
    credit
    |> cast(attrs, [:amount])
    |> maybe_put_expense(attrs)
    |> maybe_put_user(attrs)
    |> validate_required([:amount])
    |> validate_change(:amount, fn
      :amount, amount ->
        case Decimal.compare(amount, 0) do
          :gt -> []
          _ -> [amount: "must be positive"]
        end
    end)
  end

  defp maybe_put_expense(credit, attrs) do
    if expense = attrs[:expense] || attrs["expense"] do
      put_assoc(credit, :expense, expense)
    else
      credit
    end
  end

  defp maybe_put_user(credit, attrs) do
    if user = attrs[:user] || attrs["user"] do
      put_assoc(credit, :user, user)
    else
      credit
    end
  end
end
