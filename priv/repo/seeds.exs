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
  name: "Alice",
  password: "user1secret_whichmustbeatleastNcharacterslong"
}

user2_params = %{
  email: "user2@example.com",
  name: "Bob",
  password: "user2secret_whichmustbeatleastNcharacterslong"
}

user3_params = %{
  email: "user3@example.com",
  name: "Carol",
  password: "user3secret_whichmustbeatleastNcharacterslong"
}

user4_params = %{
  email: "user4@example.com",
  name: "Daniel",
  password: "user4secret_whichmustbeatleastNcharacterslong"
}

[user1, _user2, user3, user4] =
  Enum.map([user1_params, user2_params, user3_params, user4_params], fn user ->
    %User{}
    |> User.registration_changeset(user)
    |> Repo.insert!()
  end)

group1_params = %{
  name: "Last night out",
  members: [user1, user3, user4]
}

{:ok, group1} = Expenses.create_group(group1_params)

{:ok, exp1credit1} = Expenses.create_credit(%{user: user1, amount: "120.0"})
{:ok, exp1debit1} = Expenses.create_debit(%{user: user1, amount: "40.0"})
{:ok, exp1debit2} = Expenses.create_debit(%{user: user3, amount: "40.0"})
{:ok, exp1debit3} = Expenses.create_debit(%{user: user4, amount: "40.0"})

{:ok, exp1} =
  Expenses.create_expense(%{
    name: "Dinner",
    currency: :PLN,
    group: group1,
    credits: [exp1credit1],
    debits: [exp1debit1, exp1debit2, exp1debit3]
  })

{:ok, exp2credit1} = Expenses.create_credit(%{user: user3, amount: "240.0"})
{:ok, exp2debit1} = Expenses.create_debit(%{user: user1, amount: "80.0"})
{:ok, exp2debit2} = Expenses.create_debit(%{user: user3, amount: "80.0"})
{:ok, exp2debit3} = Expenses.create_debit(%{user: user4, amount: "80.0"})

{:ok, exp2} =
  Expenses.create_expense(%{
    name: "Dessert",
    currency: :PLN,
    group: group1,
    credits: [exp2credit1],
    debits: [exp2debit1, exp2debit2, exp2debit3]
  })

{:ok, exp3credit1} = Expenses.create_credit(%{user: user3, amount: "80.0"})
{:ok, exp3debit1} = Expenses.create_debit(%{user: user3, amount: "40.0"})
{:ok, exp3debit2} = Expenses.create_debit(%{user: user4, amount: "40.0"})

{:ok, exp3} =
  Expenses.create_expense(%{
    name: "Drinks",
    currency: :PLN,
    group: group1,
    credits: [exp3credit1],
    debits: [exp3debit1, exp3debit2]
  })

{:ok, exp4credit1} = Expenses.create_credit(%{user: user1, amount: "120.0"})
{:ok, exp4credit2} = Expenses.create_credit(%{user: user3, amount: "120.0"})
{:ok, exp4debit1} = Expenses.create_debit(%{user: user1, amount: "80.0"})
{:ok, exp4debit2} = Expenses.create_debit(%{user: user3, amount: "80.0"})
{:ok, exp4debit3} = Expenses.create_debit(%{user: user4, amount: "80.0"})

{:ok, exp4} =
  Expenses.create_expense(%{
    name: "More drinks",
    currency: :PLN,
    group: group1,
    credits: [exp4credit1, exp4credit2],
    debits: [exp4debit1, exp4debit2, exp4debit3]
  })

{:ok, exp5credit1} = Expenses.create_credit(%{user: user3, amount: "120.0"})
{:ok, exp5credit2} = Expenses.create_credit(%{user: user4, amount: "120.0"})
{:ok, exp5debit1} = Expenses.create_debit(%{user: user1, amount: "80.0"})
{:ok, exp5debit2} = Expenses.create_debit(%{user: user3, amount: "80.0"})
{:ok, exp5debit3} = Expenses.create_debit(%{user: user4, amount: "80.0"})

{:ok, exp5} =
  Expenses.create_expense(%{
    name: "More dessert",
    currency: :PLN,
    group: group1,
    credits: [exp5credit1, exp5credit2],
    debits: [exp5debit1, exp5debit2, exp5debit3]
  })

{:ok, exp6credit1} = Expenses.create_credit(%{user: user3, amount: "120.0"})
{:ok, exp6credit2} = Expenses.create_credit(%{user: user4, amount: "120.0"})
{:ok, exp6debit1} = Expenses.create_debit(%{user: user1, amount: "80.0"})
{:ok, exp6debit2} = Expenses.create_debit(%{user: user3, amount: "80.0"})
{:ok, exp6debit3} = Expenses.create_debit(%{user: user4, amount: "80.0"})

{:ok, exp6} =
  Expenses.create_expense(%{
    name: "American cookies",
    currency: :USD,
    group: group1,
    credits: [exp6credit1, exp6credit2],
    debits: [exp6debit1, exp6debit2, exp6debit3]
  })
