defmodule LiveReverseProxy.Core.VirtualHost do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiveReverseProxy.Core

  @primary_key {:id, Uniq.UUID, version: 7, autogenerate: true}
  @foreign_key_type Uniq.UUID
  @derive {Inspect, only: []}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "core_virtual_hosts" do
    field(:code_name, :string, default: "")

    timestamps(type: :utc_datetime)

    belongs_to(:owner, Core.Owner)
    has_many(:servers, Core.Server)
  end

  @fields ~w(code_name owner_id)a

  @doc false
  def changeset(virtual_host, attrs) do
    virtual_host
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
