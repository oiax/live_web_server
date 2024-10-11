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

  def count_administrators do
    from(a in Core.Administrator,
      join: aa in assoc(a, :active_administrator)
    )
    |> Repo.aggregate(:count)
  end

  def get_owners do
    servers_query = from(s in Core.Server, order_by: s.fqdn)

    virtual_hosts_query =
      from(vh in Core.VirtualHost,
        order_by: vh.code_name,
        preload: [servers: ^servers_query]
      )

    from(o in Core.Owner,
      join: a in assoc(o, :active_owner),
      preload: [virtual_hosts: ^virtual_hosts_query],
      order_by: a.name,
      select: %{o | name: a.name, active_owner: a}
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
    servers_query = from(s in Core.Server, order_by: s.fqdn)

    from(vh in Core.VirtualHost,
      join: o in assoc(vh, :owner),
      join: a in assoc(o, :active_owner),
      preload: [servers: ^servers_query, owner: :active_owner],
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

  def get_server(id) do
    Repo.get(Core.Server, id)
  end

  def get_administrators do
    from(a in Core.Administrator,
      join: aa in assoc(a, :active_administrator),
      order_by: aa.username,
      select: %{a | username: aa.username, active_administrator: aa}
    )
    |> Repo.all()
  end

  def get_deleted_administrators do
    from(a in Core.Administrator,
      join: da in assoc(a, :deleted_administrator),
      order_by: da.username,
      select: %{a | username: da.username}
    )
    |> Repo.all()
  end

  def get_administrator(nil), do: nil

  def get_administrator(administrator_id) do
    from(a in Core.Administrator,
      join: aa in assoc(a, :active_administrator),
      where: a.id == ^administrator_id,
      select: %{a | username: aa.username, active_administrator: aa}
    )
    |> Repo.one()
  end

  def get_inactive_administrator(administrator_id) do
    from(a in Core.Administrator,
      join: da in assoc(a, :deleted_administrator),
      where: a.id == ^administrator_id,
      select: %{a | username: da.username, deleted_administrator: da}
    )
    |> Repo.one()
  end

  def build_administrator() do
    Core.Administrator.changeset(%Core.Administrator{}, %{})
  end

  def build_administrator(%Core.Administrator{} = administrator) do
    Core.Administrator.changeset(administrator, %{})
  end

  def create_owner(owner_params) do
    owner_cs = Core.Owner.changeset(owner_params)

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:owner, owner_cs)
      |> Ecto.Multi.insert(:active_owner, fn %{owner: owner} ->
        Core.ActiveOwner.build(owner, Map.take(owner_params, ~w(name)))
      end)

    try do
      Repo.transaction(multi)
    rescue
      Ecto.ConstraintError ->
        {:error, :owner, Ecto.Changeset.add_error(owner_cs, :name, "is already taken."), %{}}
    end
  end

  def update_owner(owner, owner_params) do
    owner_cs = Core.Owner.changeset(owner, owner_params)

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:owner, owner_cs)
      |> Ecto.Multi.update(
        :active_owner,
        Core.ActiveOwner.changeset(owner.active_owner, Map.take(owner_params, ~w(name)))
      )

    try do
      Repo.transaction(multi)
    rescue
      Ecto.ConstraintError ->
        {:error, :owner, Ecto.Changeset.add_error(owner_cs, :name, "is already taken."), %{}}
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

  def create_virtual_host(new_virtual_host, virtual_host_params) do
    changeset = Core.VirtualHost.changeset(new_virtual_host, virtual_host_params)

    try do
      Repo.insert(changeset)
    rescue
      Ecto.ConstraintError ->
        {:error, Ecto.Changeset.add_error(changeset, :code_name, "is already taken.")}
    end
  end

  def update_virtual_host(changeset, virtual_host_params) do
    changeset = Core.VirtualHost.changeset(changeset, virtual_host_params)

    try do
      Repo.update(changeset)
    rescue
      Ecto.ConstraintError ->
        {:error, Ecto.Changeset.add_error(changeset, :code_name, "is already taken.")}
    end
  end

  def delete_virtual_host(virtual_host_id) do
    servers_to_be_deleted = from(s in Core.Server, where: s.virtual_host_id == ^virtual_host_id)
    vhost_to_be_deleted = from(vh in Core.VirtualHost, where: vh.id == ^virtual_host_id)

    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:deleted_servers, servers_to_be_deleted)
    |> Ecto.Multi.delete_all(:deleted_virtual_host, vhost_to_be_deleted)
    |> Repo.transaction()
  end

  def create_server(new_server, server_params) do
    changeset = Core.Server.changeset(new_server, server_params)

    try do
      Repo.insert(changeset)
    rescue
      Ecto.ConstraintError ->
        {:error, Ecto.Changeset.add_error(changeset, :fqdn, "is already taken.")}
    end
  end

  def update_server(server, server_params) do
    changeset = Core.Server.changeset(server, server_params)

    try do
      Repo.update(changeset)
    rescue
      Ecto.ConstraintError ->
        {:error, Ecto.Changeset.add_error(changeset, :fqdn, "is already taken.")}
    end
  end

  def delete_server(server_id) do
    server_to_be_deleted = from(s in Core.Server, where: s.id == ^server_id)

    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:deleted_server, server_to_be_deleted)
    |> Repo.transaction()
  end

  def create_administrator(administrator_params) do
    administrator_cs = Core.Administrator.changeset(administrator_params)

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:administrator, administrator_cs)
      |> Ecto.Multi.insert(:active_administrator, fn %{administrator: administrator} ->
        Core.ActiveAdministrator.build(
          administrator,
          Map.take(administrator_params, ~w(username))
        )
      end)

    try do
      Repo.transaction(multi)
    rescue
      Ecto.ConstraintError ->
        {
          :error,
          :administrator,
          Ecto.Changeset.add_error(administrator_cs, :username, "is already taken."),
          %{}
        }
    end
  end

  def update_administrator(administrator, administrator_params) do
    administrator_cs = Core.Administrator.changeset(administrator, administrator_params)

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:administrator, administrator_cs)
      |> Ecto.Multi.update(
        :active_administrator,
        Core.ActiveAdministrator.changeset(
          administrator.active_administrator,
          Map.take(administrator_params, ~w(username))
        )
      )

    try do
      Repo.transaction(multi)
    rescue
      Ecto.ConstraintError ->
        {:error, :administrator,
         Ecto.Changeset.add_error(administrator_cs, :username, "is already taken."), %{}}
    end
  end

  def delete_administrator(administrator_id) do
    if administrator = get_administrator(administrator_id) do
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:deleted_administrator, %Core.DeletedAdministrator{
        administrator_id: administrator_id,
        username: administrator.username
      })
      |> Ecto.Multi.delete(:active_administrator, administrator.active_administrator)
      |> Repo.transaction()
    else
      {:error, nil}
    end
  end

  def undelete_administrator(administrator_id) do
    if administrator = get_inactive_administrator(administrator_id) do
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        :active_administrator,
        %Core.ActiveAdministrator{
          administrator_id: administrator_id,
          username: administrator.username
        }
      )
      |> Ecto.Multi.delete(:deleted_administrator, administrator.deleted_administrator)
      |> Repo.transaction()
    else
      {:error, nil}
    end
  end

  def change_password(administrator, password_params) do
    password_cs = Core.Administrator.password_changeset(administrator, password_params)

    case Repo.update(password_cs) do
      {:ok, _updated_administrator} ->
        {:ok, administrator}

      {:error, changeset} ->
        {:error, :administrator, changeset, %{}}
    end
  end

  def change_my_password(administrator, password_params) do
    my_password_cs = Core.Administrator.my_password_changeset(administrator, password_params)

    case Repo.update(my_password_cs) do
      {:ok, _updated_administrator} ->
        {:ok, administrator}

      {:error, changeset} ->
        {:error, :administrator, changeset, %{}}
    end
  end
end
