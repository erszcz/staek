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
    required = ~w[amount user_id]a
    optional = ~w[expense_id]a

    debits
    |> cast(attrs, required ++ optional)
    |> validate_required(required)
    |> validate_change(:amount, fn
      :amount, amount ->
        case Decimal.compare(amount, 0) do
          :gt -> []
          _ -> [amount: "must be positive"]
        end
    end)
    |> foreign_key_constraint(:expense_id)
    |> foreign_key_constraint(:user_id)
  end
end
