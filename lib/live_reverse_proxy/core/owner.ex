defmodule LiveReverseProxy.Core.Owner do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiveReverseProxy.Core

  @primary_key {:id, Uniq.UUID, version: 7, autogenerate: true}
  @foreign_key_type Uniq.UUID
  @derive {Inspect, only: []}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "core_owners" do
    field(:name, :string, default: "")

    timestamps(type: :utc_datetime)

    has_many(:virtual_hosts, Core.VirtualHost)
  end

  @fields ~w(name)a

  @doc false
  def changeset(owner, attrs) do
    owner
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
