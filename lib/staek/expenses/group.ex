defmodule Staek.Expenses.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
