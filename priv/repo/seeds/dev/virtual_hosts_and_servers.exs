alias LiveReverseProxy.Repo
alias LiveReverseProxy.Core

owner_name_and_hostname_pairs = [
  {"Kappa", "alpha"},
  {"Kappa", "beta"},
  {"Lambda", "gamma"}
]

for {owner_name, hostname} <- owner_name_and_hostname_pairs do
  owner = Repo.get_by(Core.Owner, name: owner_name)

  vh =
    Repo.insert!(%Core.VirtualHost{
      owner: owner,
      code_name: hostname
    })

  Repo.insert!(%Core.Server{
    virtual_host: vh,
    fqdn: "#{hostname}.lvh.me"
  })
end
