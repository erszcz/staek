defmodule StaekWeb.DashboardController do
  use StaekWeb, :controller

  alias Staek.Expenses

  def view(conn, _params) do
    current_user = conn.assigns.current_user

    groups =
      Enum.map(Expenses.get_user_groups(current_user), fn group ->
        %{name: group.name, path: ~p"/groups/#{group.id}"}
      end)

    conn =
      conn
      |> assign(:groups, groups)

    render(conn, :view)
  end
end
