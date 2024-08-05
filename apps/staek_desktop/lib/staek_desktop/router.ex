defmodule StaekDesktop.Router do
  use StaekDesktop, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", StaekDesktop do
    pipe_through :api
  end
end
