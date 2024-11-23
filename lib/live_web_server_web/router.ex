defmodule LiveWebServerWeb.Router do
  use LiveWebServerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LiveWebServerWeb.Layouts, :root}
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug :protect_from_forgery
  end

  scope "/", LiveWebServerWeb, host: Application.compile_env(:live_web_server, :admin_host) do
    pipe_through [:browser, :admin]

    live "/", AdminLive, :dashboard
    live "/owners", AdminLive, :owners
    live "/owners/deleted", AdminLive, :deleted_owners
    live "/virtual_hosts", AdminLive, :virtual_hosts
    live "/servers", AdminLive, :servers
    live "/administrators", AdminLive, :administrators
    live "/administrators/deleted", AdminLive, :deleted_administrators
    live "/change_my_password", AdminLive, :change_my_password

    get "/sign_in", SessionController, :new
    post "/sign_in", SessionController, :create
    delete "/sign_out", SessionController, :delete
  end

  scope "/", LiveWebServerWeb do
    pipe_through :browser

    get "/*page", PageController, :show
  end
end
