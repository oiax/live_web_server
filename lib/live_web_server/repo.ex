defmodule LiveWebServer.Repo do
  use Ecto.Repo,
    otp_app: :live_web_server,
    adapter: Ecto.Adapters.Postgres
end
