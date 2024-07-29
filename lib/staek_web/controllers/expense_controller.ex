defmodule StaekWeb.ExpenseController do
  use StaekWeb, :controller

  alias Staek.Expenses
  alias Staek.Expenses.Expense

  def index(conn, _params) do
    expenses = Expenses.list_expenses()
    render(conn, :index, expenses: expenses)
  end

  def new(conn, %{"group_id" => group_id}) do
    changeset = Expenses.change_expense(%Expense{})

    group = Expenses.get_group!(group_id)

    assigns = %{
      changeset: changeset,
      group: %{
        id: group_id,
        default_currency: group.default_currency
      },
      members:
        Enum.map(Expenses.get_group!(group_id, [:members]).members, fn member ->
          %{
            id: member.id,
            name: member.name,
            email: member.email
          }
        end)
    }

    render(conn, :new, assigns)
  end

  def create(conn, %{"expense" => expense_params}) do
    case Expenses.create_expense(expense_params) do
      {:ok, expense} ->
        conn
        |> put_flash(:info, "Expense created successfully.")
        |> redirect(to: ~p"/expenses/#{expense}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    expense = Expenses.get_expense!(id)
    render(conn, :show, expense: expense)
  end

  def edit(conn, %{"id" => id}) do
    expense = Expenses.get_expense!(id)
    changeset = Expenses.change_expense(expense)
    render(conn, :edit, expense: expense, changeset: changeset)
  end

  def update(conn, %{"id" => id, "expense" => expense_params}) do
    expense = Expenses.get_expense!(id)

    case Expenses.update_expense(expense, expense_params) do
      {:ok, expense} ->
        conn
        |> put_flash(:info, "Expense updated successfully.")
        |> redirect(to: ~p"/expenses/#{expense}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, expense: expense, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    expense = Expenses.get_expense!(id)
    {:ok, _expense} = Expenses.delete_expense(expense)

    conn
    |> put_flash(:info, "Expense deleted successfully.")
    |> redirect(to: ~p"/expenses")
  end
end
