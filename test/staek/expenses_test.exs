defmodule Staek.ExpensesTest do
  use Staek.DataCase

  alias Staek.Expenses
  alias Staek.Expenses.GroupMembers

  describe "groups" do
    alias Staek.Expenses.Group

    import Staek.ExpensesFixtures

    @invalid_attrs %{name: nil}

    test "list_groups/0 returns all groups" do
      group = group_fixture()
      assert Expenses.list_groups() == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert Expenses.get_group!(group.id) == group
    end

    test "create_group/1 with valid data creates a group" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Group{} = group} = Expenses.create_group(valid_attrs)
      assert group.name == "some name"
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Expenses.create_group(@invalid_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      group = group_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Group{} = group} = Expenses.update_group(group, update_attrs)
      assert group.name == "some updated name"
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Expenses.update_group(group, @invalid_attrs)
      assert group == Expenses.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = Expenses.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Expenses.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = Expenses.change_group(group)
    end
  end

  describe "group_members" do
    alias Staek.Accounts.User
    alias Staek.Expenses.Group

    import Staek.AccountsFixtures
    import Staek.ExpensesFixtures

    setup do
      user1 = user_fixture()
      user2 = user_fixture()
      group1 = group_fixture()

      memberships = [
        {user1.id, group1.id},
        {user2.id, group1.id}
      ]

      Enum.each(memberships, fn {user_id, group_id} ->
        %GroupMembers{}
        |> GroupMembers.changeset(%{group_id: group_id, user_id: user_id})
        |> Repo.insert!()
      end)

      %{
        user1: user1,
        user2: user2,
        group1: group1
      }
    end

    test "User.groups returns user's groups", ctx do
      %{user1: user1, user2: user2, group1: group1} = ctx

      user1 = user1 |> Repo.preload(:groups)
      user2 = user2 |> Repo.preload(:groups)

      assert user1.groups == [group1]
      assert user2.groups == [group1]
    end

    test "Group.members returns group members", ctx do
      %{user1: user1, user2: user2, group1: group1} = ctx

      group1 = group1 |> Repo.preload(members:
        from(
          user in User,
          join: gm in GroupMembers,
          on: gm.user_id == user.id,
          order_by: user.id)
      )

      assert group1.members == Enum.sort_by([user1, user2], &(&1.id))
    end
  end
end
