defmodule Staek.Repo.Migrations.EnableGroupsCrr do
  use Ecto.Migration

  alias Staek.Repo

  @crrs ~w[groups group_members expenses credits debits]a

  def change do
    Enum.map(@crrs, &Repo.enable_crr!(&1))
  end
end
