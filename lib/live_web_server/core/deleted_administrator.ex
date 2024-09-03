defmodule LiveWebServer.Core.DeletedAdministrator do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiveWebServer.Core

  @primary_key {:id, Uniq.UUID, version: 7, autogenerate: true}
  @foreign_key_type Uniq.UUID
  @derive {Inspect, only: []}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "core_deleted_administrators" do
    field(:username, :string)

    timestamps(type: :utc_datetime)

    belongs_to(:administrator, Core.Administrator)
  end

  @doc false
  def changeset(deleted_administrator, attrs) do
    deleted_administrator
    |> cast(attrs, [])
    |> validate_required([])
  end
end
