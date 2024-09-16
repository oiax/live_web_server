defmodule LiveWebServer.Repo.Migrations.CreateCoreAdministrators do
  use Ecto.Migration

  def change do
    create table(:core_administrators, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:password_hash, :string)
      add(:superadmin, :boolean, null: false, default: false)

      timestamps(type: :utc_datetime)
    end
  end
end
