defmodule LiveWebServerWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use LiveWebServerWeb, :controller` and
  `use LiveWebServerWeb, :live_view`.
  """
  use LiveWebServerWeb, :html

  embed_templates "layouts/*"

  defp section_names do
    ~w(dashboard owners virtual_hosts servers administrators)
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, menu_visible: false)}
  end

  def handle_event("toggle_menu", _params, socket) do
    new_visibility = !socket.assigns.menu_visible
    {:noreply, assign(socket, menu_visible: new_visibility)}
  end

  defp titleize(section_name) do
    section_name
    |> Phoenix.Naming.humanize()
    |> String.split()
    |> Enum.map(&String.capitalize(&1))
    |> Enum.join(" ")
  end

  defp section_path("dashboard"), do: "/"
  defp section_path(section_name), do: ~p(/#{section_name})
end
