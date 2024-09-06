defmodule LiveWebServerWeb.SessionController do
  use LiveWebServerWeb, :controller
  alias LiveWebServer.Core

  def new(conn, _params) do
    render(conn, "new.html",
      administrator: Core.build_administrator(),
      current_administrator: nil,
      current_section_name: "",
      error_message: nil
    )
  end

  def create(conn, %{"administrator" => admin_params} = _params) do
    username = admin_params["username"]
    password = admin_params["password"]

    case Core.Auth.authenticate_administrator(username, password) do
      {:ok, admininistrator} ->
        conn
        |> put_session(:current_administrator_id, admininistrator.id)
        |> redirect(to: "/")

      {:error, message} ->
        administrator = Core.build_administrator(%Core.Administrator{username: username})

        conn
        |> delete_session(:current_administrator_id)
        |> render("new.html",
          administrator: administrator,
          current_administrator: nil,
          current_section_name: "",
          error_message: message
        )
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:current_administrator_id)
    |> redirect(to: "/")
  end
end
