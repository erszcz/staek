defmodule StaekWeb.GroupController do
  use StaekWeb, :controller

  alias Staek.Expenses
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

      expenses = group_expenses_for_user(group, current_user)

      render(conn, :show, group: group, expenses: expenses, groups: groups)
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
          creditor: String.t(),
          total_credit: Decimal.t(),
          user_debit: Decimal.t()
        }

  @spec group_expenses_for_user(any, any) :: [expense_for_user()]
  defp group_expenses_for_user(group, user) do
    [
      %{
        name: "Dinner",
        creditors: ["User1", "User2"],
        total_credit: "122.0",
        user_debit: "61.0"
      },
      %{
        name: "Drinks",
        creditors: ["User1"],
        total_credit: "222.0",
        user_debit: "111.0"
      }
    ]
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
