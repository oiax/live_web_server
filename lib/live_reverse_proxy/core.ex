defmodule LiveReverseProxy.Core do
  alias LiveReverseProxy.Core
  alias LiveReverseProxy.Repo

  @virtual_host_dir Path.expand(Path.join(__DIR__, "../../priv/static/virtual_hosts"))

  def virtual_hosts_dir do
    Application.get_env(:live_reverse_proxy, :virtual_hosts_dir) || @virtual_host_dir
  end

  def get_virtual_host(fqdn) do
    Repo.get_by(Core.VirtualHost, fqdn: fqdn)
  end
end
