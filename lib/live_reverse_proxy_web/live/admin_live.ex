defmodule LiveReverseProxyWeb.AdminLive do
  use LiveReverseProxyWeb, :live_view
  alias LiveReverseProxy.Core

  embed_templates "admin_live/*"

  def render(%{current_section_name: "dashboard"} = assigns), do: ~H"<.dashboard {assigns}/>"
  def render(%{current_section_name: "owners"} = assigns), do: ~H"<.owners {assigns}/>"

  def render(%{current_section_name: "virtual_hosts"} = assigns),
    do: ~H"<.virtual_hosts {assigns}/>"

  def render(%{current_section_name: "servers"} = assigns), do: ~H"<.servers {assigns}/>"

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:current_section_name, "dashboard")
      |> assign(:count_of_owners, Core.count_owners())
      |> assign(:count_of_virtual_hosts, Core.count_virtual_hosts())
      |> assign(:count_of_servers, Core.count_servers())

    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) when socket.assigns.live_action == :dashboard do
    socket = assign(socket, :current_section_name, "dashboard")
    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) when socket.assigns.live_action == :owners do
    socket =
      socket
      |> assign(:current_section_name, "owners")
      |> assign(:owners, Core.get_owners())

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
end
