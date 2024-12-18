defmodule LiveWebServer.Repo.Migrations.AddExpiredAtToCoreVirtualHosts do
  use Ecto.Migration

  def change do
    alter table(:core_virtual_hosts) do
      add :expired_at, :utc_datetime, null: true
    end
  end
end
