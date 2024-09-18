defmodule LiveWebServer.Core.AdministratorTest do
  use LiveWebServer.DataCase, async: true
  alias LiveWebServer.Core.Administrator

  describe "password_changeset/2" do
    test "validates password length" do
      changeset = Administrator.password_changeset(%Administrator{}, %{"password" => "short"})
      error_message = "must be at least 8 characters long"
      assert error_message in errors_on(changeset).password
    end

    test "valid password" do
      changeset =
        Administrator.password_changeset(%Administrator{}, %{"password" => "password123"})

      assert changeset.valid?
      assert errors_on(changeset) == %{}
    end
  end
end
