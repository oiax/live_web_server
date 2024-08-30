alias LiveWebServer.Repo
alias LiveWebServer.Core

names = ~w(
  Kappa
  Lambda
)

for name <- names do
  Repo.insert!(%Core.Owner{
    name: name
  })
end
