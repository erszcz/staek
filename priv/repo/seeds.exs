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
alias Staek.Expenses.GroupMembers

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
  name: "Last night out"
}

group1 =
  %Group{}
  |> Group.changeset(group1_params)
  |> Repo.insert!()

memberships = [{group1.id, user1.id}, {group1.id, user3.id}]

Enum.each(memberships, fn {group_id, user_id} ->
  %GroupMembers{}
  |> GroupMembers.changeset(%{group_id: group_id, user_id: user_id})
  |> Repo.insert!()
end)
