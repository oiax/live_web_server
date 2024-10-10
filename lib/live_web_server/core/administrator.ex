defmodule LiveWebServer.Core.Administrator do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiveWebServer.Core

  @primary_key {:id, Uniq.UUID, version: 7, autogenerate: true}
  @foreign_key_type Uniq.UUID
  @derive {Inspect, only: []}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "core_administrators" do
    field(:username, :string, virtual: true)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:superadmin, :boolean)

    field(:being_deleted, :boolean, virtual: true, default: false)

    timestamps(type: :utc_datetime)

    has_one(:active_administrator, Core.ActiveAdministrator)
    has_one(:deleted_administrator, Core.DeletedAdministrator)
  end

  @fields ~w(username)a

  @doc false
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @fields ++ [:password])
    |> validate_required(@fields ++ [:password])
    |> set_password_hash(attrs)
  end

  def changeset(administrator, attrs) do
    administrator
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end

  def password_changeset(administrator, attrs) do
    administrator
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_format(:password, ~r/.{8,}/, message: "must be at least 8 characters long")
    |> set_password_hash(attrs)
  end

  defp set_password_hash(%Ecto.Changeset{valid?: true} = changeset, attrs) do
    changeset
    |> put_change(:password_hash, Bcrypt.hash_pwd_salt(attrs["password"]))
  end

  defp set_password_hash(changeset, _attrs), do: changeset

  @doc false
  def build() do
    cast(%__MODULE__{}, %{}, [])
  end
end
