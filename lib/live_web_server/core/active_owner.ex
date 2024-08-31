defmodule LiveWebServer.Core.ActiveOwner do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiveWebServer.Core

  @primary_key {:id, Uniq.UUID, version: 7, autogenerate: true}
  @foreign_key_type Uniq.UUID
  @derive {Inspect, only: [:name]}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "core_active_owners" do
    field(:name, :string, default: "")

    timestamps(type: :utc_datetime)

    belongs_to(:owner, Core.Owner)
  end

  @fields ~w(name)a

  @doc false
  def changeset(active_owner, attrs) do
    active_owner
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end

  @doc false
  def build(owner, attrs) do
    cast(%__MODULE__{owner_id: owner.id}, attrs, @fields)
  end
end
