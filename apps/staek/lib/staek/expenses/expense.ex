defmodule Staek.Expenses.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  alias Staek.Currencies
  alias Staek.Expenses.Credit
  alias Staek.Expenses.Debit
  alias Staek.Expenses.Group

  require Currencies

  @primary_key {:id, Ecto.Nanoid, autogenerate: true}
  schema "expenses" do
    field :name, :string
    field :currency, Ecto.Enum, values: Currencies.literal_symbols()
    belongs_to :group, Group, type: Ecto.Nanoid
    has_many :credits, Credit
    has_many :debits, Debit

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expense, attrs) do
    required = [:name, :currency, :group_id]

    expense
    |> cast(attrs, required)
    |> cast_assoc(:credits, required: true)
    |> cast_assoc(:debits, required: true)
    |> validate_required(required)
    |> validate_credits_and_debits(attrs)
  end

  defp validate_credits_and_debits(changeset, attrs) do
    changeset
    |> validate_length(:credits, min: 1)
    |> validate_length(:debits, min: 1)
    |> validate_change(:credits, &do_validate_owner_uniqueness/2)
    |> validate_change(:debits, &do_validate_owner_uniqueness/2)
    |> validate_change(:credits, fn :credits, _credits ->
      credits = attrs[:credits] || []
      debits = attrs[:debits] || []
      do_validate_totals(credits, debits)
    end)
  end

  defp do_validate_owner_uniqueness(field, field_values) when field in [:credits, :debits] do
    owner_changes = Enum.map(field_values, & &1.changes.user_id)

    owners = Enum.map(field_values, & &1.data.user_id)

    all_owners =
      (owner_changes ++ owners)
      |> Enum.filter(& &1)
      |> Enum.sort()

    unique_owners = Enum.uniq(all_owners)

    case unique_owners do
      ^all_owners ->
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
