defmodule LiveReverseProxy.Repo do
  use Ecto.Repo,
    otp_app: :live_reverse_proxy,
    adapter: Ecto.Adapters.Postgres
end
