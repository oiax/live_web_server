defmodule LiveWebServer.Core.Auth do
  import Ecto.Query, warn: false
  alias LiveWebServer.Repo
  alias LiveWebServer.Core

  def authenticate_administrator(username, password) do
    from(a in Core.Administrator,
      join: aa in assoc(a, :active_administrator),
      where: aa.username == ^username
    )
    |> Repo.one()
    |> verify_password(password)
  end

  defp verify_password(nil, _) do
    Bcrypt.no_user_verify()
    {:error, "Wrong username or password"}
  end

  defp verify_password(account, password) do
    if Bcrypt.verify_pass(password, account.password_hash) do
      {:ok, account}
    else
      {:error, "Wrong username or password"}
    end
  end
end
