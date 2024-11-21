use Timex

alias LiveWebServer.Repo
alias LiveWebServer.Core

virtual_host_tuples = [
  {"Kappa", "alpha", nil},
  {"Kappa", "beta", "https://www.google.co.jp/"},
  {"Lambda", "gamma", "https://www.yahoo.co.jp/"}
]


for {owner_name, hostname, target} <- virtual_host_tuples do
  owner = Core.get_owner_by_name(owner_name)

  vh =
    Repo.insert!(%Core.VirtualHost{
      owner: owner,
      code_name: hostname,
      redirection_target: target
    })

  Repo.insert!(%Core.Server{
    virtual_host: vh,
    fqdn: "#{hostname}.lvh.me"
  })
end

owner = Core.get_owner_by_name("Kappa")
today_utc = Timex.now("Etc/UTC") |> Timex.beginning_of_day()

Repo.insert!(%Core.VirtualHost{
  owner: owner,
  code_name: "epsilon",
  redirection_target: nil,
  expired_at: today_utc
})

Repo.insert!(%Core.Server{
  virtual_host: Repo.get_by!(Core.VirtualHost, code_name: "epsilon"),
  fqdn: "epsilon.lvh.me"
})
