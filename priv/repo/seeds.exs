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

{:ok, exp1} =
  Expenses.create_expense(%{
    name: "Dinner",
    currency: :PLN,
    group_id: group1.id,
    credits: [
      %{user_id: user1.id, amount: "120.0"}
    ],
    debits: [
      %{user_id: user1.id, amount: "40.0"},
      %{user_id: user3.id, amount: "40.0"},
      %{user_id: user4.id, amount: "40.0"}
    ]
  })

{:ok, exp2} =
  Expenses.create_expense(%{
    name: "Dessert",
    currency: :PLN,
    group_id: group1.id,
    credits: [
      %{user_id: user3.id, amount: "240.0"}
    ],
    debits: [
      %{user_id: user1.id, amount: "80.0"},
      %{user_id: user3.id, amount: "80.0"},
      %{user_id: user4.id, amount: "80.0"}
    ]
  })

{:ok, exp3} =
  Expenses.create_expense(%{
    name: "Drinks",
    currency: :PLN,
    group_id: group1.id,
    credits: [
      %{user_id: user3.id, amount: "80.0"}
    ],
    debits: [
      %{user_id: user3.id, amount: "40.0"},
      %{user_id: user4.id, amount: "40.0"}
    ]
  })

{:ok, exp4} =
  Expenses.create_expense(%{
    name: "More drinks",
    currency: :PLN,
    group_id: group1.id,
    credits: [
      %{user_id: user1.id, amount: "120.0"},
      %{user_id: user3.id, amount: "120.0"}
    ],
    debits: [
      %{user_id: user1.id, amount: "80.0"},
      %{user_id: user3.id, amount: "80.0"},
      %{user_id: user4.id, amount: "80.0"}
    ]
  })

{:ok, exp5} =
  Expenses.create_expense(%{
    name: "More dessert",
    currency: :PLN,
    group_id: group1.id,
    credits: [
      %{user_id: user3.id, amount: "120.0"},
      %{user_id: user4.id, amount: "120.0"}
    ],
    debits: [
      %{user_id: user1.id, amount: "80.0"},
      %{user_id: user3.id, amount: "80.0"},
      %{user_id: user4.id, amount: "80.0"}
    ]
  })

{:ok, exp6} =
  Expenses.create_expense(%{
    name: "American cookies",
    currency: :USD,
    group_id: group1.id,
    credits: [
      %{user_id: user3.id, amount: "120.0"},
      %{user_id: user4.id, amount: "120.0"}
    ],
    debits: [
      %{user_id: user1.id, amount: "80.0"},
      %{user_id: user3.id, amount: "80.0"},
      %{user_id: user4.id, amount: "80.0"}
    ]
  })
