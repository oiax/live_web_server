defmodule LiveWebServerWeb.PageController do
  use LiveWebServerWeb, :controller
  alias LiveWebServer.Core

  def show(conn, _params) do
    case URI.new(Plug.Conn.request_url(conn)) do
      {:ok, uri} ->
        case Core.get_virtual_host(uri.host) do
          %{redirection_target: nil} = vhost -> send_page(conn, vhost, uri)
          %{redirection_target: target} -> redirect(conn, external: target)
          _ -> text(conn, "Not Found: #{uri.path}")
        end

      {:error, _} ->
        text(conn, "Not Found")
    end
  end

  defp send_page(conn, vhost, uri) do
    path =
      Path.join([
        LiveWebServer.Core.virtual_hosts_dir(),
        vhost.code_name,
        "dist",
        uri.path
      ])

    if File.exists?(path) do
      if File.dir?(path) do
        index_path = Path.join(path, "index.html")

        if File.exists?(index_path) do
          send_download(conn, {:file, index_path}, disposition: :inline)
        else
          text(conn, "Not Found: #{path}")
        end
      else
        send_download(conn, {:file, path}, disposition: :inline)
      end
    else
      text(conn, "Not Found: #{path}")
    end
  end
end
