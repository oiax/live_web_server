alias LiveWebServer.Repo
alias LiveWebServer.Core

names = ~w(
  Kappa
  Lambda
)

for name <- names do
  owner = Repo.insert!(%Core.Owner{})

  Repo.insert!(%Core.ActiveOwner{
    owner: owner,
    name: name
  })
end

owner = Repo.insert!(%Core.Owner{})

Repo.insert!(%Core.DeletedOwner{
  owner: owner,
  name: "Epsilon"
})
