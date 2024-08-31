defmodule LiveWebServer.Core do
  alias LiveWebServer.Core
  alias LiveWebServer.Repo
  import Ecto.Query, only: [from: 2]

  def count_owners do
    from(o in Core.Owner,
      join: a in assoc(o, :active_owner)
    )
    |> Repo.aggregate(:count)
  end

  def count_virtual_hosts do
    from(vh in Core.VirtualHost,
      join: o in assoc(vh, :owner),
      join: a in assoc(o, :active_owner)
    )
    |> Repo.aggregate(:count)
  end

  def count_servers do
    from(s in Core.Server,
      join: vh in assoc(s, :virtual_host),
      join: o in assoc(vh, :owner),
      join: a in assoc(o, :active_owner)
    )
    |> Repo.aggregate(:count)
  end

  def get_owners do
    from(o in Core.Owner,
      join: a in assoc(o, :active_owner),
      preload: [virtual_hosts: :servers],
      order_by: a.name,
      select: %{o | name: a.name}
    )
    |> Repo.all()
  end

  def get_deleted_owners do
    from(o in Core.Owner,
      join: d in assoc(o, :deleted_owner),
      preload: [virtual_hosts: :servers],
      order_by: d.name,
      select: %{o | name: d.name}
    )
    |> Repo.all()
  end

  def get_owner(owner_id) do
    from(o in Core.Owner,
      join: a in assoc(o, :active_owner),
      where: o.id == ^owner_id,
      select: %{o | name: a.name, active_owner: a}
    )
    |> Repo.one()
  end

  def get_inactive_owner(owner_id) do
    from(o in Core.Owner,
      join: d in assoc(o, :deleted_owner),
      where: o.id == ^owner_id,
      select: %{o | name: d.name, deleted_owner: d}
    )
    |> Repo.one()
  end

  def get_owner_by_name(name) do
    from(o in Core.Owner,
      join: a in assoc(o, :active_owner),
      where: a.name == ^name,
      preload: [virtual_hosts: :servers],
      select: %{o | name: a.name}
    )
    |> Repo.one()
  end

  def get_virtual_hosts do
    from(vh in Core.VirtualHost,
      join: o in assoc(vh, :owner),
      join: a in assoc(o, :active_owner),
      preload: [:servers, owner: :active_owner],
      order_by: vh.code_name
    )
    |> Repo.all()
    |> Enum.map(fn vh ->
      %{vh | owner: %{vh.owner | name: vh.owner.active_owner.name}}
    end)
  end

  def get_servers do
    from(s in Core.Server,
      join: vh in assoc(s, :virtual_host),
      join: o in assoc(vh, :owner),
      join: a in assoc(o, :active_owner),
      preload: [virtual_host: [owner: :active_owner]],
      order_by: s.fqdn
    )
    |> Repo.all()
    |> Enum.map(fn s ->
      vh = s.virtual_host
      %{s | virtual_host: %{vh | owner: %{vh.owner | name: vh.owner.active_owner.name}}}
    end)
  end

  @virtual_host_dir Application.compile_env(:live_web_server, :virtual_hosts_dir) ||
                      Path.expand(Path.join(__DIR__, "../../vhosts/sites"))

  def virtual_hosts_dir, do: @virtual_host_dir

  def get_virtual_host(fqdn) do
    from(vh in Core.VirtualHost,
      join: o in assoc(vh, :owner),
      join: a in assoc(o, :active_owner),
      join: s in assoc(vh, :servers),
      where: s.fqdn == ^fqdn
    )
    |> Repo.one()
  end

  def create_owner(owner_params) do
    cs = Core.Owner.changeset(owner_params)

    try do
      Repo.insert(cs)
    rescue
      Ecto.ConstraintError -> {:error, Ecto.Changeset.add_error(cs, :name, "is already taken.")}
    end
  end

  def delete_owner(owner_id) do
    if owner = get_owner(owner_id) do
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:deleted_owner, %Core.DeletedOwner{
        owner_id: owner_id,
        name: owner.name
      })
      |> Ecto.Multi.delete(:active_owner, owner.active_owner)
      |> Repo.transaction()
    else
      {:error, nil}
    end
  end

  def undelete_owner(owner_id) do
    if owner = get_inactive_owner(owner_id) do
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:active_owner, %Core.ActiveOwner{owner_id: owner_id, name: owner.name})
      |> Ecto.Multi.delete(:deleted_owner, owner.deleted_owner)
      |> Repo.transaction()
    else
      {:error, nil}
    end
  end
end