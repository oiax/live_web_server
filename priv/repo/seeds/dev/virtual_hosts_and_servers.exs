alias LiveReverseProxy.Repo
alias LiveReverseProxy.Core

Core.VirtualHost |> Repo.delete_all()

hostnames = ~w(
  alpha
  beta
  gamma
)

for hostname <- hostnames do
  vh =
    Repo.insert!(%Core.VirtualHost{
      code_name: hostname
    })

  Repo.insert!(%Core.Server{
    virtual_host: vh,
    fqdn: "#{hostname}.lvh.me"
  })
end
