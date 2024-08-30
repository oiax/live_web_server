defmodule LiveWebServerWeb.ErrorJSONTest do
  use LiveWebServerWeb.ConnCase, async: true

  test "renders 404" do
    assert LiveWebServerWeb.ErrorJSON.render("404.json", %{}) == %{
             errors: %{detail: "Not Found"}
           }
  end

  test "renders 500" do
    assert LiveWebServerWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
