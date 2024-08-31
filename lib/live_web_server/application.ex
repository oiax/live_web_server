defmodule LiveWebServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LiveWebServerWeb.Telemetry,
      LiveWebServer.Repo,
      {DNSCluster, query: Application.get_env(:live_web_server, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LiveWebServer.PubSub},
      # Start a worker by calling: LiveWebServer.Worker.start_link(arg)
      # {LiveWebServer.Worker, arg},
      # Start to serve requests, typically the last entry
      LiveWebServerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveWebServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveWebServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
