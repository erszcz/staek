defmodule StaekWeb.ExpenseController do
  use StaekWeb, :controller

  alias Staek.Expenses
  alias Staek.Expenses.Expense
  alias StaekWeb.Forms

  require Logger

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
    group_id = expense_params["group_id"] || raise "group_id not in params"

    expense_params =
      expense_params
      |> Forms.cleanup_params_array("paid_by")
      |> Forms.cleanup_params_array("split_among")

    expense_params = prepare_expense_params(expense_params)

    case Expenses.create_expense(expense_params) do
      {:ok, expense} ->
        conn
        |> put_flash(:info, "Added expense: #{expense.name}")
        |> redirect(to: ~p"/groups/#{expense.group_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.notice(create_expense: :error, changeset: changeset)

        conn
        |> put_flash(:error, "Failed to add expense :(")
        |> redirect(to: ~p"/groups/#{group_id}")
    end
  end

  defp prepare_expense_params(params) do
    ## TODO: support non-equal credits/debits shares
    credits = prepare_equal_credits(params)
    debits = prepare_equal_debits(params)

    params
    |> Map.put("credits", credits)
    |> Map.put("debits", debits)
  end

  defp prepare_equal_credits(params) do
    amount = Decimal.new(params["amount"])
    n = length(params["paid_by"])

    Enum.map(params["paid_by"], fn creditor_id ->
      %{user_id: creditor_id, amount: Decimal.div(amount, n)}
    end)
  end

  defp prepare_equal_debits(params) do
    amount = Decimal.new(params["amount"])
    n = length(params["split_among"])

    Enum.map(params["split_among"], fn debtor_id ->
      %{user_id: debtor_id, amount: Decimal.div(amount, n)}
    end)
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
