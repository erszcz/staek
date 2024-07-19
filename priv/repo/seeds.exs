# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Staek.Repo.insert!(%Staek.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Staek.Repo
alias Staek.Accounts.User
alias Staek.Expenses

user1_params = %{
  email: "user1@example.com",
  password: "user1secret_whichmustbeatleastNcharacterslong"
}

user2_params = %{
  email: "user2@example.com",
  password: "user2secret_whichmustbeatleastNcharacterslong"
}

user3_params = %{
  email: "user3@example.com",
  password: "user3secret_whichmustbeatleastNcharacterslong"
}

[user1, _user2, user3] =
  Enum.map([user1_params, user2_params, user3_params], fn user ->
    %User{}
    |> User.registration_changeset(user)
    |> Repo.insert!()
  end)

group1_params = %{
  name: "Last night out",
  members: [user1, user3]
}

{:ok, group1} = Expenses.create_group(group1_params)

{:ok, exp1} =
  Expenses.create_expense(%{name: "Dinner", total: Decimal.new("120.0"), group: group1})

{:ok, exp2} =
  Expenses.create_expense(%{name: "Drinks", total: Decimal.new("220.0"), group: group1})
