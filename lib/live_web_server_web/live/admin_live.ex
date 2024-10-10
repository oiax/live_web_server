defmodule LiveWebServerWeb.AdminLive do
  use LiveWebServerWeb, :live_view
  alias LiveWebServer.Core

  embed_templates "admin_live/*"

  @impl Phoenix.LiveView
  def render(%{current_section_name: "dashboard"} = assigns), do: ~H"<.dashboard {assigns} />"
  def render(%{current_section_name: "owners"} = assigns), do: ~H"<.owners {assigns} />"

  def render(%{current_section_name: "deleted_owners"} = assigns),
    do: ~H"<.deleted_owners {assigns} />"

  def render(%{current_section_name: "virtual_hosts"} = assigns),
    do: ~H"<.virtual_hosts {assigns} />"

  def render(%{current_section_name: "servers"} = assigns), do: ~H"<.servers {assigns} />"

  def render(%{current_section_name: "administrators"} = assigns) do
    ~H"<.administrators {assigns} />"
  end

  def render(%{current_section_name: "deleted_administrators"} = assigns) do
    ~H"<.deleted_administrators {assigns} />"
  end

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    administrator = Core.get_administrator(session["current_administrator_id"])

    if administrator do
      socket =
        socket
        |> assign(:owners, [])
        |> assign(:virtual_hosts, [])
        |> assign(:servers, [])
        |> assign(:administrators, [])
        |> assign(:current_administrator, administrator)

      {:ok, socket}
    else
      {:ok, redirect(socket, external: "/sign_in")}
    end
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) when socket.assigns.live_action == :dashboard do
    socket =
      socket
      |> assign(:current_section_name, "dashboard")
      |> assign(:count_of_owners, Core.count_owners())
      |> assign(:count_of_virtual_hosts, Core.count_virtual_hosts())
      |> assign(:count_of_servers, Core.count_servers())
      |> assign(:count_of_administrators, Core.count_administrators())
      |> assign(:excited, false)

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) when socket.assigns.live_action == :owners do
    socket =
      socket
      |> assign(:current_section_name, "owners")
      |> assign(:owners, Core.get_owners())
      |> assign(:owner_changeset, nil)
      |> assign(:new_owner_changeset, nil)
      |> assign(:new_virtual_host_changeset, nil)
      |> assign(:excited, false)

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) when socket.assigns.live_action == :deleted_owners do
    socket =
      socket
      |> assign(:current_section_name, "deleted_owners")
      |> assign(:owners, Core.get_deleted_owners())
      |> assign(:owner_changeset, nil)
      |> assign(:new_owner_changeset, nil)
      |> assign(:excited, false)

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) when socket.assigns.live_action == :virtual_hosts do
    socket =
      socket
      |> assign(:current_section_name, "virtual_hosts")
      |> assign(:virtual_hosts, Core.get_virtual_hosts())
      |> assign(:virtual_host_changeset, nil)
      |> assign(:new_server_changeset, nil)
      |> assign(:server_changeset, nil)
      |> assign(:excited, false)

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) when socket.assigns.live_action == :servers do
    socket =
      socket
      |> assign(:current_section_name, "servers")
      |> assign(:servers, Core.get_servers())
      |> assign(:server_changeset, nil)
      |> assign(:excited, false)

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) when socket.assigns.live_action == :administrators do
    socket =
      socket
      |> assign(:current_section_name, "administrators")
      |> assign(:administrators, Core.get_administrators())
      |> assign(:administrator_changeset, nil)
      |> assign(:password_changeset, nil)
      |> assign(:new_administrator_changeset, nil)
      |> assign(:new_virtual_host_changeset, nil)
      |> assign(:excited, false)

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket)
      when socket.assigns.live_action == :deleted_administrators do
    socket =
      socket
      |> assign(:current_section_name, "deleted_administrators")
      |> assign(:administrators, Core.get_deleted_administrators())
      |> assign(:administrator_changeset, nil)
      |> assign(:new_administrator_changeset, nil)
      |> assign(:excited, false)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel", _params, socket) do
    socket =
      socket
      |> assign(:new_owner_changeset, nil)
      |> assign(:owner_changeset, nil)
      |> assign(:new_virtual_host_changeset, nil)
      |> assign(:virtual_host_changeset, nil)
      |> assign(:new_server_changeset, nil)
      |> assign(:server_changeset, nil)
      |> assign(:new_administrator_changeset, nil)
      |> assign(:administrator_changeset, nil)
      |> assign(:password_changeset, nil)
      |> update(:owners, &reset_objects/1)
      |> update(:virtual_hosts, &reset_objects/1)
      |> update(:servers, &reset_objects/1)
      |> update(:administrators, &reset_objects/1)
      |> assign(:excited, false)

    {:noreply, socket}
  end

  def handle_event("new_owner", _params, socket) do
    socket =
      socket
      |> assign(:new_owner_changeset, Core.Owner.build())
      |> assign(:excited, true)

    {:noreply, socket}
  end

  def handle_event("create_owner", %{"owner" => owner_params}, socket) do
    case Core.create_owner(owner_params) do
      {:ok, _owner} ->
        reset_owners(socket)

      {:error, :owner, changeset, _} ->
        socket = assign(socket, :new_owner_changeset, changeset)
        {:noreply, socket}
    end
  end

  def handle_event("edit_owner", %{"owner-id" => owner_id}, socket) do
    if owner = Core.get_owner(owner_id) do
      socket =
        socket
        |> assign(:owner_changeset, Core.Owner.changeset(owner, %{}))
        |> assign(:excited, true)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("update_owner", %{"owner" => owner_params}, socket) do
    case Core.update_owner(socket.assigns.owner_changeset.data, owner_params) do
      {:ok, _owner} ->
        reset_owners(socket)

      {:error, :owner, changeset, _} ->
        socket = assign(socket, :owner_changeset, changeset)
        {:noreply, socket}
    end
  end

  def handle_event("delete_owner", %{"owner-id" => owner_id}, socket) do
    owners =
      Enum.map(socket.assigns.owners, fn owner ->
        %{owner | being_deleted: owner.id == owner_id}
      end)

    socket =
      socket
      |> assign(:owners, owners)
      |> assign(:excited, true)

    {:noreply, socket}
  end

  def handle_event("do_delete_owner", %{"owner-id" => owner_id}, socket) do
    case Core.delete_owner(owner_id) do
      {:ok, _owner} -> reset_owners(socket)
      {:error, _changeset} -> reset_owners(socket)
    end
  end

  def handle_event("undelete_owner", %{"owner-id" => owner_id}, socket) do
    case Core.undelete_owner(owner_id) do
      {:ok, _owner} -> reset_undelete_owners(socket)
      {:error, _changeset} -> reset_undelete_owners(socket)
    end
  end

  def handle_event("new_virtual_host", %{"owner-id" => owner_id}, socket) do
    if owner = Enum.find(socket.assigns.owners, &(&1.id == owner_id)) do
      socket =
        socket
        |> assign(:new_virtual_host_changeset, Core.VirtualHost.build(owner, %{}))
        |> assign(:excited, true)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("create_virtual_host", %{"virtual_host" => virtual_host_params}, socket) do
    if cs = socket.assigns.new_virtual_host_changeset do
      case Core.create_virtual_host(cs.data, virtual_host_params) do
        {:ok, _owner} ->
          reset_owners(socket)

        {:error, changeset} ->
          socket = assign(socket, :new_virtual_host_changeset, changeset)
          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("edit_virtual_host", %{"virtual-host-id" => virtual_host_id}, socket) do
    if vh = LiveWebServer.Repo.get(Core.VirtualHost, virtual_host_id) do
      socket =
        socket
        |> assign(:virtual_host_changeset, Core.VirtualHost.changeset(vh, %{}))
        |> assign(:excited, true)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("update_virtual_host", %{"virtual_host" => vh_params}, socket) do
    case Core.update_virtual_host(socket.assigns.virtual_host_changeset.data, vh_params) do
      {:ok, _owner} ->
        reset_virtual_hosts(socket)

      {:error, changeset} ->
        socket = assign(socket, :virtual_host_changeset, changeset)
        {:noreply, socket}
    end
  end

  def handle_event("delete_virtual_host", %{"virtual-host-id" => virtual_host_id}, socket) do
    virtual_hosts =
      Enum.map(socket.assigns.virtual_hosts, fn vh ->
        %{vh | being_deleted: vh.id == virtual_host_id}
      end)

    socket =
      socket
      |> assign(:virtual_hosts, virtual_hosts)
      |> assign(:excited, true)

    {:noreply, socket}
  end

  def handle_event("do_delete_virtual_host", %{"virtual-host-id" => virtual_host_id}, socket) do
    case Core.delete_virtual_host(virtual_host_id) do
      {:ok, _} -> reset_virtual_hosts(socket)
      {:error, _, _, _} -> reset_virtual_hosts(socket)
    end
  end

  def handle_event("new_server", %{"virtual-host-id" => virtual_host_id}, socket) do
    if vh = Enum.find(socket.assigns.virtual_hosts, &(&1.id == virtual_host_id)) do
      socket =
        socket
        |> assign(:new_server_changeset, Core.Server.build(vh, %{}))
        |> assign(:excited, true)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("create_server", %{"server" => server_params}, socket) do
    if cs = socket.assigns.new_server_changeset do
      case Core.create_server(cs.data, server_params) do
        {:ok, _server} ->
          reset_virtual_hosts(socket)

        {:error, changeset} ->
          socket = assign(socket, :new_server_changeset, changeset)
          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("edit_server", %{"server-id" => server_id}, socket) do
    if server = LiveWebServer.Repo.get(Core.Server, server_id) do
      socket =
        socket
        |> assign(:server_changeset, Core.Server.changeset(server, %{}))
        |> assign(:excited, true)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("update_server", %{"server" => server_params}, socket) do
    case Core.update_server(socket.assigns.server_changeset.data, server_params) do
      {:ok, _server} ->
        dbg(X)
        reset_servers(socket)

      {:error, changeset} ->
        dbg(Y)
        socket = assign(socket, :server_changeset, changeset)
        {:noreply, socket}
    end
  end

  def handle_event("delete_server", %{"server-id" => server_id}, socket) do
    servers =
      Enum.map(socket.assigns.servers, fn server ->
        %{server | being_deleted: server.id == server_id}
      end)

    socket =
      socket
      |> assign(:servers, servers)
      |> assign(:excited, true)

    {:noreply, socket}
  end

  def handle_event("do_delete_server", %{"server-id" => server_id}, socket) do
    case Core.delete_server(server_id) do
      {:ok, _} -> reset_servers(socket)
      {:error, _, _, _} -> reset_servers(socket)
    end
  end

  def handle_event("new_administrator", _params, socket) do
    socket =
      socket
      |> assign(:new_administrator_changeset, Core.Administrator.build())
      |> assign(:excited, true)

    {:noreply, socket}
  end

  def handle_event("create_administrator", %{"administrator" => administrator_params}, socket) do
    case Core.create_administrator(administrator_params) do
      {:ok, _administrator} ->
        reset_administrators(socket)

      {:error, :administrator, changeset, _} ->
        socket = assign(socket, :new_administrator_changeset, changeset)
        {:noreply, socket}
    end
  end

  def handle_event("edit_administrator", %{"administrator-id" => administrator_id}, socket) do
    if administrator = Core.get_administrator(administrator_id) do
      socket =
        socket
        |> assign(:administrator_changeset, Core.Administrator.changeset(administrator, %{}))
        |> assign(:excited, true)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("update_administrator", %{"administrator" => administrator_params}, socket) do
    case Core.update_administrator(
           socket.assigns.administrator_changeset.data,
           administrator_params
         ) do
      {:ok, _administrator} ->
        reset_administrators(socket)

      {:error, :administrator, changeset, _} ->
        socket = assign(socket, :administrator_changeset, changeset)
        {:noreply, socket}
    end
  end

  def handle_event("delete_administrator", %{"administrator-id" => administrator_id}, socket) do
    administrators =
      Enum.map(socket.assigns.administrators, fn administrator ->
        %{administrator | being_deleted: administrator.id == administrator_id}
      end)

    socket =
      socket
      |> assign(:administrators, administrators)
      |> assign(:excited, true)

    {:noreply, socket}
  end

  def handle_event("do_delete_administrator", %{"administrator-id" => administrator_id}, socket) do
    case Core.delete_administrator(administrator_id) do
      {:ok, _administrator} -> reset_administrators(socket)
      {:error, _changeset} -> reset_administrators(socket)
    end
  end

  def handle_event("undelete_administrator", %{"administrator-id" => administrator_id}, socket) do
    case Core.undelete_administrator(administrator_id) do
      {:ok, _administrator} -> reset_undelete_administrators(socket)
      {:error, _changeset} -> reset_undelete_administrators(socket)
    end
  end

  def handle_event("change_password", %{"administrator-id" => administrator_id}, socket) do
    if administrator = Core.get_administrator(administrator_id) do
      changeset = Core.Administrator.password_changeset(administrator, %{})
      changeset = %{changeset | errors: []}

      socket =
        socket
        |> assign(:password_changeset, changeset)
        |> assign(:excited, true)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("do_change_password", %{"administrator" => administrator_params}, socket) do
    case Core.change_password(socket.assigns.password_changeset.data, administrator_params) do
      {:ok, _administrator} ->
        socket = put_flash(socket, :info, "Password successfully updated.")
        Process.send_after(self(), :clear_flash, 1000)
        reset_administrators(socket)

      {:error, :administrator, changeset, _} ->
        socket = assign(socket, :password_changeset, changeset)
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  defp reset_owners(socket) do
    socket =
      socket
      |> assign(:owners, Core.get_owners())
      |> assign(:owner_changeset, nil)
      |> assign(:new_owner_changeset, nil)
      |> assign(:new_virtual_host_changeset, nil)
      |> assign(:excited, false)

    {:noreply, socket}
  end

  defp reset_undelete_owners(socket) do
    socket =
      socket
      |> assign(:owners, Core.get_deleted_owners())
      |> assign(:owner_changeset, nil)
      |> assign(:new_virtual_host_changeset, nil)
      |> assign(:excited, false)

    {:noreply, socket}
  end

  defp reset_virtual_hosts(socket) do
    socket =
      socket
      |> assign(:virtual_hosts, Core.get_virtual_hosts())
      |> assign(:virtual_host_changeset, nil)
      |> assign(:new_server_changeset, nil)
      |> assign(:excited, false)

    {:noreply, socket}
  end

  defp reset_servers(socket) do
    socket =
      socket
      |> assign(:virtual_hosts, Core.get_virtual_hosts())
      |> assign(:servers, Core.get_servers())
      |> assign(:server_changeset, nil)
      |> assign(:excited, false)

    {:noreply, socket}
  end

  defp reset_administrators(socket) do
    socket =
      socket
      |> assign(:administrators, Core.get_administrators())
      |> assign(:administrator_changeset, nil)
      |> assign(:new_administrator_changeset, nil)
      |> assign(:password_changeset, nil)
      |> assign(:excited, false)

    {:noreply, socket}
  end

  defp reset_undelete_administrators(socket) do
    socket =
      socket
      |> assign(:administrators, Core.get_deleted_administrators())
      |> assign(:administrator_changeset, nil)
      |> assign(:excited, false)

    {:noreply, socket}
  end

  defp reset_objects(objects) do
    Enum.map(objects, fn obj -> %{obj | being_deleted: false} end)
  end

  defp editing_owner?(_owner_host, nil), do: false

  defp editing_owner?(owner, owner_changeset) do
    owner_changeset.data.id == owner.id
  end

  defp row_class(index) when rem(index, 2) == 0, do: "bg-base-200"
  defp row_class(index) when rem(index, 2) == 1, do: "bg-base-300"

  defp owner_row_span(owner, new_virtual_host_changeset) do
    if adding_virtual_host?(owner, new_virtual_host_changeset) do
      length(owner.virtual_hosts) + 1
    else
      if owner.virtual_hosts == [], do: 1, else: length(owner.virtual_hosts)
    end
  end

  defp adding_virtual_host?(_owner, nil), do: false

  defp adding_virtual_host?(owner, new_virtual_host_changeset) do
    Ecto.Changeset.get_field(new_virtual_host_changeset, :owner_id) == owner.id
  end

  defp editing_virtual_host?(_virtual_host, nil), do: false

  defp editing_virtual_host?(virtual_host, virtual_host_changeset) do
    virtual_host_changeset.data.id == virtual_host.id
  end

  defp remaining_virtual_hosts(%{virtual_hosts: []}, _new_virtual_host_changeset), do: []

  defp remaining_virtual_hosts(owner, new_virtual_host_changeset) do
    if adding_virtual_host?(owner, new_virtual_host_changeset) do
      owner.virtual_hosts
    else
      tl(owner.virtual_hosts)
    end
  end

  def owner_action_cell_class(%{being_deleted: false} = _owner), do: ""
  def owner_action_cell_class(%{being_deleted: true} = _owner), do: "bg-gray-400"

  defp virtual_host_row_span(virtual_host, new_server_changeset) do
    len = length(virtual_host.servers)
    len = if len == 0, do: 1, else: len

    if adding_server?(virtual_host, new_server_changeset) do
      len + 1
    else
      len
    end
  end

  defp virtual_host_actions_row_span(virtual_host, _new_server_changeset) do
    len = length(virtual_host.servers)
    if len == 0, do: 1, else: len
  end

  defp adding_server?(_virtual_host, nil), do: false

  defp adding_server?(virtual_host, new_server_changeset) do
    Ecto.Changeset.get_field(new_server_changeset, :virtual_host_id) == virtual_host.id
  end

  defp remaining_servers(%{servers: []}, _new_server_changeset), do: []

  defp remaining_servers(virtual_host, new_server_changeset) do
    if adding_server?(virtual_host, new_server_changeset) do
      virtual_host.servers
    else
      tl(virtual_host.servers)
    end
  end

  defp editing_server?(_server, nil), do: false

  defp editing_server?(server, server_changeset) do
    server_changeset.data.id == server.id
  end

  def administrator_action_cell_class(%{being_deleted: false} = _owner), do: ""
  def administrator_action_cell_class(%{being_deleted: true} = _owner), do: "bg-gray-400"

  defp editing_administrator?(_, nil), do: false

  defp editing_administrator?(administrator, administrator_changeset) do
    administrator_changeset.data.id == administrator.id
  end

  defp changing_password?(_, nil), do: false

  defp changing_password?(administrator, password_hash_changeset) do
    password_hash_changeset.data.id == administrator.id
  end
end
