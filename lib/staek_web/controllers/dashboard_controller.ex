defmodule StaekWeb.DashboardController do
  use StaekWeb, :controller

  def view(conn, _params) do
    render(conn, :view, assigns: [])
  end
end
