defmodule LiveReverseProxy.Repo.Migrations.CreateCoreVirtualHosts do
  use Ecto.Migration

  def change do
    create table(:core_virtual_hosts, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:fqdn, :string, null: false)

      timestamps(type: :utc_datetime)
    end
  end
end
