defmodule LiveReverseProxy.Repo.Migrations.CreateCoreVirtualHosts do
  use Ecto.Migration

  def change do
    create table(:core_virtual_hosts, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:code_name, :string, null: false)

      add(
        :owner_id,
        references("core_owners", type: :binary_id, on_delete: :delete_all),
        null: false
      )

      timestamps(type: :utc_datetime)
    end

    create(unique_index(:core_virtual_hosts, :code_name))
  end
end
