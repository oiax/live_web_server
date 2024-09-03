defmodule LiveWebServer.Repo.Migrations.CreateCoreDeletedAdministrators do
  use Ecto.Migration

  def change do
    create table(:core_deleted_administrators, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:username, :string, null: false)

      add(
        :administrator_id,
        references("core_administrators", type: :binary_id, on_delete: :delete_all),
        null: false
      )

      timestamps(type: :utc_datetime)
    end

    create(unique_index(:core_deleted_administrators, :administrator_id))
  end
end
