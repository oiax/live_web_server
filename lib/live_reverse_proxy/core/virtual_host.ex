defmodule LiveReverseProxy.Core.VirtualHost do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Uniq.UUID, version: 7, autogenerate: true}
  @foreign_key_type Uniq.UUID
  @derive {Inspect, only: []}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "core_virtual_hosts" do
    field(:fqdn, :string, default: "")

    timestamps(type: :utc_datetime)
  end

  @fields ~w(fqdn)a

  @doc false
  def changeset(virtual_host, attrs) do
    virtual_host
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
