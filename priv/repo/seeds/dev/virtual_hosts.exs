alias LiveReverseProxy.Repo
alias LiveReverseProxy.Core

Core.VirtualHost |> Repo.delete_all()

hostnames = ~w(
  alpha
  beta
  gamma
  delta
)

for hostname <- hostnames do
  Repo.insert!(%Core.VirtualHost{
    fqdn: "#{hostname}.lvh.me"
  })
end
