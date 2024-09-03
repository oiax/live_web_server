alias LiveWebServer.Repo
alias LiveWebServer.Core

usernames = ~w(
  taro
  hanako
  jiro
)

for username <- usernames do
  administrator =
    Repo.insert!(%Core.Administrator{
      password_hash: Bcrypt.hash_pwd_salt(username <> "888"),
    })

  Repo.insert!(%Core.ActiveAdministrator{
    administrator: administrator,
    username: username
  })
end

deleted_usernames = ~w(
  saburo
  kyoko
)

for username <- deleted_usernames do
  administrator =
    Repo.insert!(%Core.Administrator{
      password_hash: Bcrypt.hash_pwd_salt(username <> "888"),
    })

  Repo.insert!(%Core.DeletedAdministrator{
    administrator: administrator,
    username: username
  })
end
