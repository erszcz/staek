defmodule StaekWeb.ErrorJSONTest do
  use StaekWeb.ConnCase, async: true

  test "renders 404" do
    assert StaekWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert StaekWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
