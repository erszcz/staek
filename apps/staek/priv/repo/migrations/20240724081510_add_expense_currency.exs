defmodule Staek.Repo.Migrations.AddExpenseCurrency do
  use Ecto.Migration

  def change do
    alter table(:expenses) do
      add :currency, :text, null: false, default: "EUR"
    end
  end
end
