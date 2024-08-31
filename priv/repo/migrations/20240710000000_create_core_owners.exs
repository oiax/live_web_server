defmodule LiveWebServer.Repo.Migrations.CreateCoreOwners do
  use Ecto.Migration

  def change do
    create table(:core_owners, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string, null: false)

      timestamps(type: :utc_datetime)
    end

    create(unique_index(:core_owners, :name))
  end
end
