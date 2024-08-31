defmodule LiveWebServer.Core.Owner do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiveWebServer.Core

  @primary_key {:id, Uniq.UUID, version: 7, autogenerate: true}
  @foreign_key_type Uniq.UUID
  @derive {Inspect, only: []}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "core_owners" do
    field(:name, :string, virtual: true, default: "")
    field(:to_be_deleted, :boolean, virtual: true, default: false)

    timestamps(type: :utc_datetime)

    has_one(:active_owner, Core.ActiveOwner)
    has_one(:deleted_owner, Core.DeletedOwner)
    has_many(:virtual_hosts, Core.VirtualHost)
  end

  @fields ~w(name)a

  @doc false
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end

  def changeset(owner, attrs) do
    owner
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end

  @doc false
  def build() do
    cast(%__MODULE__{}, %{}, [])
  end
end
