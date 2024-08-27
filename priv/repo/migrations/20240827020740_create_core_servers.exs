defmodule LiveReverseProxy.Repo.Migrations.CreateCoreServers do
  use Ecto.Migration

  def change do
    create table(:core_servers, primary_key: false) do
      add(:id, :binary_id, primary_key: true)

      add(
        :virtual_host_id,
        references("core_virtual_hosts", type: :binary_id, on_delete: :delete_all),
        null: false
      )

      add(:fqdn, :string, null: false)

      timestamps(type: :utc_datetime)
    end

    create(unique_index(:core_servers, :fqdn))
  end
end
