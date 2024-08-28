defmodule LiveReverseProxyWeb.AdminLive do
  use LiveReverseProxyWeb, :live_view

  embed_templates "admin_live/*"

  def render(%{current_section_name: "dashboard"} = assigns), do: ~H"<.dashboard assigns/>"
  def render(%{current_section_name: "owners"} = assigns), do: ~H"<.owners assigns/>"
  def render(%{current_section_name: "virtual_hosts"} = assigns), do: ~H"<.virtual_hosts assigns/>"
  def render(%{current_section_name: "servers"} = assigns), do: ~H"<.servers assigns/>"

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:current_section_name, "dashboard")

    {:ok, socket}
  end

  @available_section_names ~w(dashboard owners virtual_hosts servers)a

  def handle_params(_params, _uri, socket) when socket.assigns.live_action in @available_section_names do
    socket = assign(socket, :current_section_name, Atom.to_string(socket.assigns.live_action))
    {:noreply, socket}
  end
end
