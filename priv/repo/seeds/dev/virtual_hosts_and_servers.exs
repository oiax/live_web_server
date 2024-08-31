alias LiveWebServer.Repo
alias LiveWebServer.Core

owner_name_and_hostname_pairs = [
  {"Kappa", "alpha"},
  {"Kappa", "beta"},
  {"Lambda", "gamma"}
]

for {owner_name, hostname} <- owner_name_and_hostname_pairs do
  owner = Core.get_owner_by_name(owner_name)

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
