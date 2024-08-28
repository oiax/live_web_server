defmodule LiveReverseProxyWeb.Router do
  use LiveReverseProxyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LiveReverseProxyWeb.Layouts, :root}
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug :protect_from_forgery
  end

  scope "/", LiveReverseProxyWeb, host: Application.compile_env(:live_reverse_proxy, :admin_host) do
    pipe_through [:browser, :admin]

    live "/", AdminLive, :dashboard
    live "/owners", AdminLive, :owners
    live "/virtual_hosts", AdminLive, :virtual_hosts
    live "/servers", AdminLive, :servers
  end

  scope "/", LiveReverseProxyWeb do
    pipe_through :browser

    get "/*page", PageController, :show
  end
end
