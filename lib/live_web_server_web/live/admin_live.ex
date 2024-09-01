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

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:owners, [])
      |> assign(:virtual_hosts, [])
      |> assign(:servers, [])

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) when socket.assigns.live_action == :dashboard do
    socket =
      socket
      |> assign(:current_section_name, "dashboard")
      |> assign(:count_of_owners, Core.count_owners())
      |> assign(:count_of_virtual_hosts, Core.count_virtual_hosts())
      |> assign(:count_of_servers, Core.count_servers())

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) when socket.assigns.live_action == :owners do
    socket =
      socket
      |> assign(:current_section_name, "owners")
      |> assign(:owners, Core.get_owners())
      |> assign(:new_owner_changeset, nil)
      |> assign(:new_virtual_host_changeset, nil)

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) when socket.assigns.live_action == :deleted_owners do
    socket =
      socket
      |> assign(:current_section_name, "deleted_owners")
      |> assign(:owners, Core.get_deleted_owners())
      |> assign(:new_owner_changeset, nil)

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) when socket.assigns.live_action == :virtual_hosts do
    socket =
      socket
      |> assign(:current_section_name, "virtual_hosts")
      |> assign(:virtual_hosts, Core.get_virtual_hosts())
      |> assign(:new_server_changeset, nil)

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) when socket.assigns.live_action == :servers do
    socket =
      socket
      |> assign(:current_section_name, "servers")
      |> assign(:servers, Core.get_servers())

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel", _params, socket) do
    socket =
      socket
      |> assign(:new_owner_changeset, nil)
      |> assign(:new_virtual_host_changeset, nil)
      |> assign(:new_server_changeset, nil)
      |> update(:owners, fn owners ->
        Enum.map(owners, fn owner -> %{owner | being_edited: false, being_deleted: false} end)
      end)
      |> update(:virtual_hosts, fn virtual_hosts ->
        Enum.map(virtual_hosts, fn vh -> %{vh | being_edited: false} end)
      end)

    {:noreply, socket}
  end

  def handle_event("new_owner", _params, socket) do
    socket = assign(socket, :new_owner_changeset, Core.Owner.build())
    {:noreply, socket}
  end

  def handle_event("create_owner", %{"owner" => owner_params}, socket) do
    case Core.create_owner(owner_params) do
      {:ok, _owner} ->
        socket =
          socket
          |> assign(:owners, Core.get_owners())
          |> assign(:new_owner_changeset, nil)

        {:noreply, socket}

      {:error, :owner, changeset, _} ->
        socket = assign(socket, :new_owner_changeset, changeset)
        {:noreply, socket}
    end
  end

  def handle_event("edit_owner", %{"owner-id" => owner_id}, socket) do
    if owner = Enum.find(socket.assigns.owners, fn owner -> owner.id == owner_id end) do
      owners =
        Enum.map(socket.assigns.owners, fn owner ->
          %{owner | being_edited: owner.id == owner_id}
        end)

      socket =
        socket
        |> assign(:owner_changeset, Core.Owner.changeset(owner, %{}))
        |> assign(:owners, owners)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("update_owner", %{"owner" => owner_params}, socket) do
    case Core.update_owner(socket.assigns.owner_changeset.data, owner_params) do
      {:ok, _owner} ->
        socket =
          socket
          |> assign(:owners, Core.get_owners())
          |> assign(:owner_changeset, nil)

        {:noreply, socket}

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

    {:noreply, assign(socket, :owners, owners)}
  end

  def handle_event("do_delete_owner", %{"owner-id" => owner_id}, socket) do
    case Core.delete_owner(owner_id) do
      {:ok, _owner} ->
        socket = assign(socket, :owners, Core.get_owners())
        {:noreply, socket}

      {:error, _changeset} ->
        socket = assign(socket, :owners, Core.get_owners())
        {:noreply, socket}
    end
  end

  def handle_event("undelete_owner", %{"owner-id" => owner_id}, socket) do
    case Core.undelete_owner(owner_id) do
      {:ok, _owner} ->
        socket = assign(socket, :owners, Core.get_deleted_owners())
        {:noreply, socket}

      {:error, _changeset} ->
        socket = assign(socket, :owners, Core.get_deleted_owners())
        {:noreply, socket}
    end
  end

  def handle_event("new_virtual_host", %{"owner-id" => owner_id}, socket) do
    if owner = Enum.find(socket.assigns.owners, &(&1.id == owner_id)) do
      socket = assign(socket, :new_virtual_host_changeset, Core.VirtualHost.build(owner, %{}))
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("create_virtual_host", %{"virtual_host" => virtual_host_params}, socket) do
    if cs = socket.assigns.new_virtual_host_changeset do
      case Core.create_virtual_host(cs.data, virtual_host_params) do
        {:ok, _owner} ->
          socket =
            socket
            |> assign(:owners, Core.get_owners())
            |> assign(:new_virtual_host_changeset, nil)

          {:noreply, socket}

        {:error, changeset} ->
          socket = assign(socket, :new_virtual_host_changeset, changeset)
          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("edit_virtual_host", %{"virtual-host-id" => virtual_host_id}, socket) do
    if vh = Enum.find(socket.assigns.virtual_hosts, fn vh -> vh.id == virtual_host_id end) do
      virtual_hosts =
        Enum.map(socket.assigns.virtual_hosts, fn vh ->
          %{vh | being_edited: vh.id == virtual_host_id}
        end)

      socket =
        socket
        |> assign(:virtual_host_changeset, Core.VirtualHost.changeset(vh, %{}))
        |> assign(:virtual_hosts, virtual_hosts)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("update_virtual_host", %{"virtual_host" => vh_params}, socket) do
    case Core.update_virtual_host(socket.assigns.virtual_host_changeset.data, vh_params) do
      {:ok, _owner} ->
        socket =
          socket
          |> assign(:virtual_hosts, Core.get_virtual_hosts())
          |> assign(:virtual_host_changeset, nil)

        {:noreply, socket}

      {:error, changeset} ->
        socket = assign(socket, :virtual_host_changeset, changeset)
        {:noreply, socket}
    end
  end

  def handle_event("new_server", %{"virtual-host-id" => virtual_host_id}, socket) do
    if vh = Enum.find(socket.assigns.virtual_hosts, &(&1.id == virtual_host_id)) do
      socket = assign(socket, :new_server_changeset, Core.Server.build(vh, %{}))
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("create_server", %{"server" => server_params}, socket) do
    if cs = socket.assigns.new_server_changeset do
      case Core.create_server(cs.data, server_params) do
        {:ok, _server} ->
          socket =
            socket
            |> assign(:virtual_hosts, Core.get_virtual_hosts())
            |> assign(:new_server_changeset, nil)

          {:noreply, socket}

        {:error, changeset} ->
          socket = assign(socket, :new_server_changeset, changeset)
          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  defp row_class(index) when rem(index, 2) == 0, do: "bg-base-200"
  defp row_class(index) when rem(index, 2) == 1, do: "bg-base-300"

  defp owner_row_span(owner, new_virtual_host_changeset) do
    if adding_virtual_host?(owner, new_virtual_host_changeset) do
      length(owner.virtual_hosts) + 1
    else
      length(owner.virtual_hosts)
    end
  end

  defp adding_virtual_host?(_owner, nil), do: false

  defp adding_virtual_host?(owner, new_virtual_host_changeset) do
    Ecto.Changeset.get_field(new_virtual_host_changeset, :owner_id) == owner.id
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
end
