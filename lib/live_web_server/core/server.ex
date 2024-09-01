defmodule LiveWebServer.Core.Server do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiveWebServer.Core

  @primary_key {:id, Uniq.UUID, version: 7, autogenerate: true}
  @foreign_key_type Uniq.UUID
  @derive {Inspect, only: []}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "core_servers" do
    field(:fqdn, :string, default: "")

    timestamps(type: :utc_datetime)

    belongs_to(:virtual_host, Core.VirtualHost)
  end

  @fields ~w(fqdn virtual_host_id)a
  @fqdn_regex ~r/^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2,6}$/

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> validate_format(:fqdn, @fqdn_regex)
  end

  @doc false
  def build(virtual_host, attrs) do
    cast(%__MODULE__{virtual_host_id: virtual_host.id}, attrs, @fields)
  end
end
