defmodule StaekDesktop.APIController do
  use StaekDesktop, :controller

  def index(conn, _params) do
    conn
    |> send_resp(200, "ok")
  end
end
