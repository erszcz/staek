defmodule StaekWeb.DashboardController do
  use StaekWeb, :controller

  alias Staek.Expenses

  def view(conn, _params) do
    current_user = conn.assigns[:current_user]
    conn = if current_user do
      conn
      |> assign(:groups, Expenses.get_user_groups(current_user))
    else
      conn
    end

    render(conn, :view)
  end
end
