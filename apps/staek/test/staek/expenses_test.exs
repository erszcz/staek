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

  describe "group_members" do
    alias Staek.Expenses.Group

    import Staek.AccountsFixtures
    import Staek.ExpensesFixtures

    setup do
      user1 = user_fixture()
      user2 = user_fixture()
      group1 = group_fixture(%{members: [user1, user2]})

      %{
        user1: user1,
        user2: user2,
        group1: group1
      }
    end

    test "are accessible on users", ctx do
      %{user1: user1, user2: user2, group1: group1} = ctx

      user1 = user1 |> Repo.preload(:groups)
      user2 = user2 |> Repo.preload(:groups)

      assert Enum.map(user1.groups, & &1.id) == [group1.id]
      assert Enum.map(user2.groups, & &1.id) == [group1.id]
    end

    test "are accessible on groups", ctx do
      %{user1: user1, user2: user2, group1: group1} = ctx

      assert group1.members == Enum.sort_by([user1, user2], & &1.id)
    end
  end

  describe "expenses" do
    alias Staek.Expenses.Expense

    import Staek.ExpensesFixtures

    @invalid_attrs %{name: nil}
    @invalid_name @invalid_attrs
    @invalid_currency %{name: "some name", currency: nil}

    test "list_expenses/0 returns all expenses" do
      expense = expense_fixture()
      assert Enum.map(Expenses.list_expenses(), & &1.id) == [expense.id]
    end

    test "get_expense!/1 returns the expense with given id" do
      expense = expense_fixture()
      assert Expenses.get_expense!(expense.id).id == expense.id
    end

    test "create_expense/1 with valid data creates an expense" do
      credit = %{
        user_id: System.unique_integer([:positive]),
        amount: "120.5"
      }
      debit = %{
        user_id: System.unique_integer([:positive]),
        amount: "120.5"
      }
      valid_attrs = %{
        group_id: Ecto.Nanoid.autogenerate(),
        name: "some name",
        currency: :PLN,
        credits: [credit],
        debits: [debit]
      }

      assert {:ok, %Expense{} = expense} = Expenses.create_expense(valid_attrs)
      assert expense.name == "some name"
      assert expense.currency == :PLN
    end

    test "create_expense/1 with invalid name returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Expenses.create_expense(@invalid_name)
    end

    test "create_expense/1 with invalid currency returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Expenses.create_expense(@invalid_currency)
    end

    test "update_expense/2 with valid data updates the expense" do
      expense = expense_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Expense{} = expense} = Expenses.update_expense(expense, update_attrs)
      assert expense.name == "some updated name"
    end

    test "update_expense/2 with invalid data returns error changeset" do
      expense = expense_fixture()
      assert {:error, %Ecto.Changeset{}} = Expenses.update_expense(expense, @invalid_attrs)
      assert expense == Expenses.get_expense!(expense.id)
    end

    test "delete_expense/1 deletes the expense" do
      expense = expense_fixture()
      assert {:ok, %Expense{}} = Expenses.delete_expense(expense)
      assert_raise Ecto.NoResultsError, fn -> Expenses.get_expense!(expense.id) end
    end

    test "change_expense/1 returns a expense changeset" do
      expense = expense_fixture()
      assert %Ecto.Changeset{} = Expenses.change_expense(expense)
    end
  end

  describe "group expenses" do
    import Staek.ExpensesFixtures

    setup do
      group1 = group_fixture()
      exp1 = expense_fixture(group_id: group1.id)
      exp2 = expense_fixture(group_id: group1.id)

      %{
        group1: group1,
        exp1: exp1,
        exp2: exp2
      }
    end

    test "are accessible", ctx do
      %{group1: group1, exp1: exp1, exp2: exp2} = ctx

      group1 =
        group1
        |> Repo.preload(:expenses)

      assert Enum.map(group1.expenses, & &1.id) == [exp1.id, exp2.id]
    end
  end

  describe "expense debits and credits assocs" do
    import Staek.AccountsFixtures
    import Staek.ExpensesFixtures

    setup do
      user1 = user_fixture()
      user2 = user_fixture()

      credit1 = %{
        user_id: System.unique_integer([:positive]),
        amount: Decimal.new("120.5")
      }
      debit1 = %{
        user_id: System.unique_integer([:positive]),
        amount: Decimal.new("120.5")
      }

      exp1 = expense_fixture(credits: [credit1], debits: [debit1])

      %{
        user1: user1,
        user2: user2,
        credit1: credit1,
        debit1: debit1,
        exp1: exp1
      }
    end

    test "are accessible", ctx do
      %{credit1: credit1, debit1: debit1, exp1: exp1} = ctx

      exp1 =
        exp1
        |> Repo.preload([:credits, :debits])

      assert Enum.map(exp1.credits, &Map.take(&1, [:amount, :user_id])) == [credit1]
      assert Enum.map(exp1.debits, &Map.take(&1, [:amount, :user_id])) == [debit1]
    end

    test "allow access to and from users", ctx do
      %{
        credit1: credit1,
        debit1: debit1,
        user1: user1,
        user2: user2
      } = ctx

      [user1, user2] = Enum.map([user1, user2], &Repo.preload(&1, [:credits, :debits]))

      assert credit1.user_id == user1.id
      assert debit1.user_id == user2.id
      assert Enum.map(user1.credits, & &1.id) == [credit1.id]
      assert Enum.map(user1.debits, & &1.id) == []
      assert Enum.map(user2.credits, & &1.id) == []
      assert Enum.map(user2.debits, & &1.id) == [debit1.id]
    end
  end

  describe "expense debits and credits" do
    import Staek.AccountsFixtures
    import Staek.ExpensesFixtures

    setup do
      [user1, user2, user3, user4] = Enum.map(1..4, fn _ -> user_fixture() end)

      %{
        user1: user1,
        user2: user2,
        user3: user3,
        user4: user4
      }
    end

    test "unequal totals fail validation", ctx do
      %{user1: user1, user2: user2} = ctx

      {:ok, credit1} = Expenses.create_credit(%{user: user1, amount: "120.0"})
      {:ok, debit1} = Expenses.create_debit(%{user: user2, amount: "40.0"})

      assert {:error, changeset} =
               Expenses.create_expense(%{
                 name: "Totals don't match",
                 currency: :PLN,
                 credits: [credit1],
                 debits: [debit1]
               })

      assert changeset.errors == [
               credits: {
                 "total credit is not equal to total debit",
                 [
                   total_credit: Decimal.new("120.0"),
                   total_debit: Decimal.new("40.0")
                 ]
               }
             ]
    end

    test ": creditors must be unique", ctx do
      %{user1: user1} = ctx

      {:ok, credit1} = Expenses.create_credit(%{user: user1, amount: "60.0"})
      {:ok, credit2} = Expenses.create_credit(%{user: user1, amount: "60.0"})
      {:ok, debit1} = Expenses.create_debit(%{user: user1, amount: "120.0"})

      assert {:error, changeset} =
               Expenses.create_expense(%{
                 name: "Creditors are not unique",
                 currency: :PLN,
                 credits: [credit1, credit2],
                 debits: [debit1]
               })

      assert match?(
               [
                 credits: {
                   "creditors not unique",
                   [duplicate_user_ids: [_]]
                 }
               ],
               changeset.errors
             )
    end

    test ": debtors must be unique", ctx do
      %{user1: user1} = ctx

      {:ok, credit1} = Expenses.create_credit(%{user: user1, amount: "120.0"})
      {:ok, debit1} = Expenses.create_debit(%{user: user1, amount: "60.0"})
      {:ok, debit2} = Expenses.create_debit(%{user: user1, amount: "60.0"})

      assert {:error, changeset} =
               Expenses.create_expense(%{
                 name: "Debtors are not unique",
                 currency: :PLN,
                 credits: [credit1],
                 debits: [debit1, debit2]
               })

      assert match?(
               [
                 debits: {
                   "debtors not unique",
                   [duplicate_user_ids: [_]]
                 }
               ],
               changeset.errors
             )
    end

    test "amounts have to be positive", ctx do
      %{user1: user1} = ctx

      assert {:error, %Ecto.Changeset{}} = Expenses.create_credit(%{user: user1, amount: "0"})
      assert {:error, %Ecto.Changeset{}} = Expenses.create_debit(%{user: user1, amount: "-3"})
    end
  end
end
