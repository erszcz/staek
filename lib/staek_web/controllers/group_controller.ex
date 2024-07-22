defmodule StaekWeb.GroupController do
  use StaekWeb, :controller

  alias Staek.Accounts
  alias Staek.Accounts.User
  alias Staek.Expenses
  alias Staek.Expenses.Credit
  alias Staek.Expenses.Debit
  alias Staek.Expenses.Expense
  alias Staek.Expenses.Group

  def index(conn, _params) do
    groups = Expenses.list_groups()
    render(conn, :index, groups: groups)
  end

  def new(conn, _params) do
    changeset = Expenses.change_group(%Group{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"group" => group_params}) do
    current_user = conn.assigns.current_user

    group_params =
      Map.merge(
        %{"members" => [current_user]},
        group_params
      )

    case Expenses.create_group(group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group created successfully.")
        |> redirect(to: ~p"/groups/#{group}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    try do
      group = Expenses.get_group!(id, [:expenses])

      current_user = conn.assigns.current_user

      groups =
        Enum.map(Expenses.get_user_groups(current_user), fn group ->
          %{name: group.name, href: ~p"/groups/#{group.id}"}
        end)

      expenses_for_user =
        group.id
        |> Expenses.get_group_expenses()
        |> Enum.map(&prepare_expense_for_user(&1, current_user))

      render(conn, :show, group: group, expenses: expenses_for_user, groups: groups)
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(404)
        |> render(StaekWeb.ErrorHTML, "404.html")
        |> halt()
    end
  end

  @type expense_for_user() :: %{
          name: String.t(),
          who_paid:
            {:current_user_paid, Decimal.t()}
            | {:another_user_paid, String.t(), Decimal.t()}
            | {:n_users_paid, pos_integer(), Decimal.t()},
          user_debt:
            {:current_user_lent, Decimal.t()}
            | {:another_user_lent, String.t(), Decimal.t()}
            | {:current_user_borrowed, Decimal.t()}
            | :not_involved
        }

  @spec prepare_expense_for_user(%Expense{}, %User{}) :: expense_for_user()
  defp prepare_expense_for_user(expense, current_user) do
    credits = expense.credits
    debits = expense.debits

    current_user_credits = Enum.filter(credits, &(&1.user_id == current_user.id))
    current_user_debits = Enum.filter(debits, &(&1.user_id == current_user.id))

    who_paid =
      case credits do
        [%Credit{} = c] = ^current_user_credits ->
          {:current_user_paid, c.amount}

        [%Credit{user_id: creditor_id} = c] ->
          {:another_user_paid, Accounts.get_user!(creditor_id).email, c.amount}

        [_ | _] ->
          {:n_users_paid, length(credits),
           Enum.reduce(credits, 0, fn credit, acc ->
             Decimal.add(acc, credit.amount)
           end)}
      end

    user_debt =
      case {who_paid, current_user_credits, current_user_debits} do
        {{:current_user_paid, _}, _, _} ->
          {:current_user_lent,
           Enum.reduce(debits, 0, fn debit, acc ->
             if debit.user_id != current_user.id do
               Decimal.add(acc, debit.amount)
             else
               acc
             end
           end)}

        {{:another_user_paid, another_user, _}, _, [%Debit{} = d]} ->
          {:another_user_lent, another_user, d.amount}

        {{:another_user_paid, _, _}, _, []} ->
          :not_involved

        {{:n_users_paid, _, _}, [%Credit{} = c], [%Debit{} = d]} ->
          case Decimal.compare(c.amount, d.amount) do
            :lt ->
              {:current_user_borrowed, Decimal.sub(d.amount, c.amount)}

            _ ->
              {:current_user_lent, Decimal.sub(c.amount, d.amount)}
          end

        {{:n_users_paid, _, _}, [], [%Debit{} = d]} ->
          {:current_user_borrowed, d.amount}
      end

    %{
      name: expense.name,
      who_paid: who_paid,
      user_debt: user_debt
    }
  end

  def edit(conn, %{"id" => id}) do
    group = Expenses.get_group!(id)
    changeset = Expenses.change_group(group)
    render(conn, :edit, group: group, changeset: changeset)
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Expenses.get_group!(id)

    case Expenses.update_group(group, group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group updated successfully.")
        |> redirect(to: ~p"/groups/#{group}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, group: group, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    group = Expenses.get_group!(id)
    {:ok, _group} = Expenses.delete_group(group)

    conn
    |> put_flash(:info, "Group deleted successfully.")
    |> redirect(to: ~p"/groups")
  end
end
