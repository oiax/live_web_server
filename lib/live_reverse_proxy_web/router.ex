defmodule LiveReverseProxyWeb.Router do
  use LiveReverseProxyWeb, :router
  import LiveAdmin.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LiveReverseProxyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/admin", LiveReverseProxyWeb do
    pipe_through :browser

    live_admin "/" do
      admin_resource("/virtual_hosts", LiveReverseProxy.Admin.VirtualHost)
    end
  end

  scope "/", LiveReverseProxyWeb do
    pipe_through :browser

    get "/*page", PageController, :show
  end
end
