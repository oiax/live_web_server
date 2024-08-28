defmodule LiveReverseProxy.Core do
  alias LiveReverseProxy.Core
  alias LiveReverseProxy.Repo
  import Ecto.Query, only: [from: 2]

  def count_owners, do: Repo.aggregate(Core.Owner, :count)
  def count_virtual_hosts, do: Repo.aggregate(Core.VirtualHost, :count)
  def count_servers, do: Repo.aggregate(Core.Server, :count)

  def get_owners do
    from(o in Core.Owner,
      preload: [virtual_hosts: :servers],
      order_by: o.name
    )
    |> Repo.all()
  end

  def get_virtual_hosts do
    from(vh in Core.VirtualHost,
      preload: [:owner, :servers],
      order_by: vh.code_name
    )
    |> Repo.all()
  end

  def get_servers do
    from(s in Core.Server,
      preload: [virtual_host: :owner],
      order_by: s.fqdn
    )
    |> Repo.all()
  end

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

  def create_owner(owner_params) do
    owner_params
    |> Core.Owner.changeset()
    |> Repo.insert()
  end
end
