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

{:ok, exp1credit1} = Expenses.create_credit(%{user: user1, amount: "120.0"})
{:ok, exp1debit1} = Expenses.create_debit(%{user: user1, amount: "70.0"})
{:ok, exp1debit2} = Expenses.create_debit(%{user: user3, amount: "50.0"})

{:ok, exp1} =
  Expenses.create_expense(%{
    name: "Dinner",
    group: group1,
    credits: [exp1credit1],
    debits: [exp1debit1, exp1debit2]
  })

{:ok, exp2credit1} = Expenses.create_credit(%{user: user3, amount: "220.0"})
{:ok, exp2debit1} = Expenses.create_debit(%{user: user3, amount: "120.0"})
{:ok, exp2debit2} = Expenses.create_debit(%{user: user1, amount: "100.0"})

{:ok, exp2} =
  Expenses.create_expense(%{
    name: "Drinks",
    group: group1,
    credits: [exp2credit1],
    debits: [exp2debit1, exp2debit2]
  })
