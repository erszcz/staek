defmodule Staek.Repo.Migrations.AddGroupDefaultCurrency do
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add :default_currency, :text, null: false, default: "EUR"
    end
  end
end
