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
alias Staek.Expenses.Group

user1 = %{
  email: "user1@example.com",
  password: "user1secret_whichmustbeatleastNcharacterslong"
}

user2 = %{
  email: "user2@example.com",
  password: "user2secret_whichmustbeatleastNcharacterslong"
}

user3 = %{
  email: "user3@example.com",
  password: "user3secret_whichmustbeatleastNcharacterslong"
}

Enum.each([user1, user2, user3], fn user ->
  %User{}
  |> User.registration_changeset(user)
  |> Repo.insert!()
end)

group1 = %{
  name: "Last night out"
}

%Group{}
|> Group.changeset(group1)
|> Repo.insert!()
