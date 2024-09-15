defmodule LiveWebServer.Core.VirtualHost do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiveWebServer.Core

  @primary_key {:id, Uniq.UUID, version: 7, autogenerate: true}
  @foreign_key_type Uniq.UUID
  @derive {Inspect, only: []}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "core_virtual_hosts" do
    field(:code_name, :string, default: "")
    field(:redirection_target, :string)
    field(:being_deleted, :boolean, virtual: true, default: false)

    timestamps(type: :utc_datetime)

    belongs_to(:owner, Core.Owner)
    has_many(:servers, Core.Server)
  end

  @fields ~w(code_name owner_id)a
  @optional_fields ~w(redirection_target)a

  @doc false
  def changeset(virtual_host, attrs) do
    virtual_host
    |> cast(attrs, @fields ++ @optional_fields)
    |> validate_required(@fields)
    |> validate_format(:code_name, ~r/\A[a-z][0-9a-z_]*\z/)
    |> validate_redirection_target()
  end

  @doc false
  def build(owner, attrs) do
    cast(%__MODULE__{owner_id: owner.id}, attrs, @fields)
  end

  def validate_redirection_target(changeset) do
    target = get_field(changeset, :redirection_target) || ""

    if target == "" do
      changeset
    else
      {result, _uri} = URI.new(target)

      if String.starts_with?(target, ["http://", "https://"]) and result == :ok do
        changeset
      else
        add_error(changeset, :redirection_target, "is invalid.")
      end
    end
  end
end
