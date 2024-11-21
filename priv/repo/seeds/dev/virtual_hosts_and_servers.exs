use Timex

alias LiveWebServer.Repo
alias LiveWebServer.Core

today_utc = Timex.now("Etc/UTC") |> Timex.beginning_of_day()


virtual_host_tuples = [
  {"Kappa", "epsilon", nil,today_utc},
  {"Kappa", "alpha", nil,nil},
  {"Kappa", "beta", "https://www.google.co.jp/",nil},
  {"Lambda", "gamma", "https://www.yahoo.co.jp/",nil}
]


for {owner_name, hostname, target,expired_at} <- virtual_host_tuples do
  owner = Core.get_owner_by_name(owner_name)

  vh =
    Repo.insert!(%Core.VirtualHost{
      owner: owner,
      code_name: hostname,
      redirection_target: target,
      expired_at: expired_at
    })

  Repo.insert!(%Core.Server{
    virtual_host: vh,
    fqdn: "#{hostname}.lvh.me"
  })
end
