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
  def handle_event("new_owner", _params, socket) do
    socket = assign(socket, :new_owner_changeset, Core.Owner.build())
    {:noreply, socket}
  end

  def handle_event("cancel", _params, socket) do
    socket =
      socket
      |> assign(:new_owner_changeset, nil)
      |> update(:owners, fn owners ->
        Enum.map(owners, fn owner -> %{owner | being_edited: false, being_deleted: false} end)
      end)

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
end
