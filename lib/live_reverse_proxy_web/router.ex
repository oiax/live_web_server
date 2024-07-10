defmodule LiveReverseProxyWeb.Router do
  use LiveReverseProxyWeb, :router

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

  scope "/", LiveReverseProxyWeb do
    pipe_through :browser

    get "/*page", PageController, :show
  end
end
