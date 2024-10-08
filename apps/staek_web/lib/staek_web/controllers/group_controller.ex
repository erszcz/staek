defmodule StaekWeb.GroupController do
  use StaekWeb, :controller

  alias Staek.Accounts
  alias Staek.Accounts.User
  alias Staek.Expenses
  alias Staek.Expenses.Credit
  alias Staek.Expenses.Debit
  alias Staek.Expenses.Expense
  alias Staek.Expenses.Group
  alias StaekWeb.Forms

  require Logger

  def index(conn, _params) do
    groups = Expenses.list_groups()
    render(conn, :index, groups: groups)
  end

  def new(conn, _params) do
    group = %Group{}
    changeset = Expenses.change_group(group)
    users = Accounts.all_users()

    assigns = %{
      group: group,
      changeset: changeset,
      users: users
    }

    render(conn, :new, assigns)
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
        render(conn, :new, changeset: changeset, users: Accounts.all_users())
    end
  end

  def show(conn, %{"id" => id}) do
    group = Expenses.get_group!(id, [:expenses, :members])

    current_user = conn.assigns.current_user

    groups =
      Enum.map(Expenses.get_user_groups(current_user), fn group ->
        %{name: group.name, href: ~p"/groups/#{group.id}"}
      end)

    expenses = Expenses.get_group_expenses(group.id)

    expenses_for_user = Enum.map(expenses, &prepare_expense_for_user(&1, current_user))

    balances = balances_from_expenses(expenses)

    members =
      Enum.map(group.members, fn member ->
        %{
          name: member.name,
          href: ""
        }
      end)

    assigns = %{
      group: group,
      expenses: expenses_for_user,
      groups: groups,
      balances: balances,
      members: members
    }

    render(conn, :show, assigns)
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
          {:another_user_paid, Accounts.get_user!(creditor_id).name, c.amount}

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

        {{:n_users_paid, _, _}, [], []} ->
          :not_involved
      end

    %{
      name: expense.name,
      currency: expense.currency,
      who_paid: who_paid,
      user_debt: user_debt
    }
  end

  defp balances_from_expenses(expenses) do
    expenses_by_currency = Enum.group_by(expenses, & &1.currency)

    Enum.flat_map(expenses_by_currency, &balances_from_expenses_by_currency/1)
    |> Enum.group_by(& &1.user)
    |> Enum.map(fn {user, balances} ->
      %{
        user: user,
        href: "",
        balances: Enum.map(balances, &Map.drop(&1, [:user]))
      }
    end)
  end

  defp balances_from_expenses_by_currency({currency, expenses}) do
    credits = Enum.flat_map(expenses, & &1.credits)
    debits = Enum.flat_map(expenses, & &1.debits)

    credits_by_user = Enum.group_by(credits, & &1.user_id, & &1.amount)
    debits_by_user = Enum.group_by(debits, & &1.user_id, & &1.amount)

    all_user_ids =
      (Map.keys(credits_by_user) ++ Map.keys(debits_by_user))
      |> Enum.uniq()

    Enum.map(all_user_ids, fn user_id ->
      total_credit = Enum.reduce(credits_by_user[user_id] || [], Decimal.new(0), &Decimal.add/2)
      total_debit = Enum.reduce(debits_by_user[user_id] || [], Decimal.new(0), &Decimal.add/2)
      total = Decimal.sub(total_credit, total_debit)

      %{
        user: Accounts.get_user!(user_id).name,
        currency: currency,
        status:
          case Decimal.compare(total, 0) do
            :gt -> :gets_back
            _ -> :owes
          end,
        amount: Decimal.abs(total)
      }
    end)
  end

  def edit(conn, %{"id" => id}) do
    group = Expenses.get_group!(id, [:members])
    changeset = Expenses.change_group(group)
    members = group.members
    users = Accounts.all_users()

    assigns = %{
      group: group,
      changeset: changeset,
      members: members,
      users: users
    }

    render(conn, :edit, assigns)
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group_params =
      group_params
      |> Forms.cleanup_params_array("members")
      |> Map.update("members", [], &Accounts.get_users!(&1))
      |> IO.inspect(label: :group_params)

    group = Expenses.get_group!(id, [:members])

    case Expenses.update_group(group, group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group updated successfully.")
        |> redirect(to: ~p"/groups/#{group}")

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.notice(update_group: :error, changeset: changeset)

        assigns = %{
          group: group,
          changeset: changeset,
          members: group.members,
          users: Accounts.all_users()
        }

        conn
        |> render(:edit, assigns)
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
