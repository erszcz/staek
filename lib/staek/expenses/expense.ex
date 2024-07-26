defmodule Staek.Expenses.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  alias Staek.Currencies
  alias Staek.Expenses.Credit
  alias Staek.Expenses.Debit
  alias Staek.Expenses.Group

  require Currencies

  schema "expenses" do
    field :name, :string
    field :currency, Ecto.Enum, values: Currencies.literal_symbols()
    belongs_to :group, Group
    has_many :credits, Credit
    has_many :debits, Debit

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expense, attrs) do
    expense
    |> cast(attrs, [:name, :currency])
    |> maybe_put_group(attrs)
    |> maybe_put_credits(attrs)
    |> maybe_put_debits(attrs)
    |> validate_required([:name, :currency])
    |> validate_credits_and_debits(attrs)
  end

  defp maybe_put_group(expense, attrs) do
    if group = attrs["group"] || attrs[:group] do
      put_assoc(expense, :group, group)
    else
      expense
    end
  end

  defp maybe_put_credits(expense, attrs) do
    if credits = attrs[:credits] || attrs["credits"] do
      put_assoc(expense, :credits, credits)
    else
      expense
    end
  end

  defp maybe_put_debits(expense, attrs) do
    if debits = attrs[:debits] || attrs["debits"] do
      put_assoc(expense, :debits, debits)
    else
      expense
    end
  end

  defp validate_credits_and_debits(changeset, attrs) do
    changeset
    |> validate_change(:credits, &do_validate_owner_uniqueness/2)
    |> validate_change(:debits, &do_validate_owner_uniqueness/2)
    |> validate_change(:credits, fn :credits, _credits ->
      credits = attrs[:credits] || []
      debits = attrs[:debits] || []
      do_validate_totals(credits, debits)
    end)
  end

  defp do_validate_owner_uniqueness(field, field_values) when field in [:credits, :debits] do
    owners = Enum.map(field_values, & &1.data.user_id) |> Enum.sort()
    unique_owners = Enum.uniq(owners)

    case unique_owners do
      ^owners ->
        []

      _ ->
        owners_name =
          case field do
            :credits -> "creditors"
            :debits -> "debtors"
          end

        [
          {field,
           {
             "#{owners_name} not unique",
             duplicate_user_ids: owners -- unique_owners
           }}
        ]
    end
  end

  defp do_validate_totals(credits, debits) do
    total_credit = Enum.reduce(credits, 0, &Decimal.add(&1.amount, &2))
    total_debit = Enum.reduce(debits, 0, &Decimal.add(&1.amount, &2))

    case Decimal.compare(total_credit, total_debit) do
      :eq ->
        []

      _ ->
        [
          credits: {
            "total credit is not equal to total debit",
            total_credit: total_credit, total_debit: total_debit
          }
        ]
    end
  end
end
