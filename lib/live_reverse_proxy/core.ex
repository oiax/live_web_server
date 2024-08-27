defmodule LiveReverseProxy.Core do
  alias LiveReverseProxy.Core
  alias LiveReverseProxy.Repo
  import Ecto.Query, only: [from: 2]

  @virtual_host_dir Application.compile_env(:live_reverse_proxy, :virtual_hosts_dir) ||
                      Path.expand(Path.join(__DIR__, "../../vhosts/sites"))

  def virtual_hosts_dir, do: @virtual_host_dir

  def get_virtual_host(fqdn) do
    from(vh in Core.VirtualHost,
      join: s in assoc(vh, :servers),
      where: s.fqdn == ^fqdn
    )
    |> Repo.one()
  end
end
