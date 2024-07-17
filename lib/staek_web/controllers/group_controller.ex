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
    group = Expenses.get_group!(id)
    render(conn, :show, group: group)
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
