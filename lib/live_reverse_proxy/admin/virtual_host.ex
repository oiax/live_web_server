defmodule LiveReverseProxy.Admin.VirtualHost do
  use LiveAdmin.Resource,
    schema: LiveReverseProxy.Core.VirtualHost,
    immutable_fields: ~w(inserted_at updated_at)a
end
