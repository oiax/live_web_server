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

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
