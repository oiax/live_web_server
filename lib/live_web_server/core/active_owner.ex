defmodule LiveWebServer.Core.ActiveOwner do
  use Ecto.Schema
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
end
