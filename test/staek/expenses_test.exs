defmodule Staek.ExpensesTest do
  use Staek.DataCase

  alias Staek.Expenses

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
end
