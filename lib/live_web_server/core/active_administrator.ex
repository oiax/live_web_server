defmodule LiveWebServer.Core.ActiveAdministrator do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiveWebServer.Core

  @primary_key {:id, Uniq.UUID, version: 7, autogenerate: true}
  @foreign_key_type Uniq.UUID
  @derive {Inspect, only: []}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "core_active_administrators" do
    field(:username, :string)

    timestamps(type: :utc_datetime)

    belongs_to(:administrator, Core.Administrator)
  end

   @fields ~w(username)a

  @doc false
  def changeset(active_administrator, attrs) do
    active_administrator
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end

  @doc false
  def build(administrator, attrs) do
    cast(%__MODULE__{administrator_id: administrator.id}, attrs, @fields)
  end
end
