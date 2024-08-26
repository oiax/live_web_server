defmodule LiveReverseProxy.Core do
  alias LiveReverseProxy.Core
  alias LiveReverseProxy.Repo

  @virtual_host_dir Application.compile_env(:live_reverse_proxy, :virtual_hosts_dir) ||
                      Path.expand(Path.join(__DIR__, "../../vhosts/sites"))

  def virtual_hosts_dir, do: @virtual_host_dir

  def get_virtual_host(fqdn) do
    Repo.get_by(Core.VirtualHost, fqdn: fqdn)
  end
end
