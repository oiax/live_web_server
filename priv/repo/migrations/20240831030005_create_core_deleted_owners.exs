defmodule LiveWebServer.Repo.Migrations.CreateCoreDeletedOwners do
  use Ecto.Migration

  def change do
    create table(:core_deleted_owners, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string, null: false)

      add(
        :owner_id,
        references("core_owners", type: :binary_id, on_delete: :delete_all),
        null: false
      )

      timestamps(type: :utc_datetime)
    end

    create(unique_index(:core_deleted_owners, :owner_id))
  end
end
