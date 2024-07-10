defmodule LiveReverseProxy.Core do
  def virtual_hosts_dir do
    Application.get_env(:live_reverse_proxy, :virtual_hosts_dir) ||
      Application.app_dir(:live_reverse_proxy, "priv/static/virtual_hosts")
  end
end
