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

  describe "my_password_changeset/2" do
    setup do
      administrator = %Administrator{
        username: "test_admin",
        password_hash: Bcrypt.hash_pwd_salt("old_password"),
        superadmin: false
      }

      {:ok, administrator: administrator}
    end

    test "validates required fields", %{administrator: administrator} do
      changeset = Administrator.my_password_changeset(administrator, %{})

      assert changeset.valid? == false

      assert %{current_password: ["can't be blank"], new_password: ["can't be blank"]} =
               errors_on(changeset)
    end

    test "validates current password", %{administrator: administrator} do
      changeset =
        Administrator.my_password_changeset(administrator, %{
          "current_password" => "wrong_password",
          "new_password" => "new_password123"
        })

      assert changeset.valid? == false
      assert %{current_password: ["Current password is incorrect"]} = errors_on(changeset)
    end

    test "validates new password length", %{administrator: administrator} do
      changeset =
        Administrator.my_password_changeset(administrator, %{
          "current_password" => "old_password",
          "new_password" => "short"
        })

      assert changeset.valid? == false
      assert %{new_password: ["must be at least 8 characters long"]} = errors_on(changeset)
    end

    test "updates password hash when valid", %{administrator: administrator} do
      changeset =
        Administrator.my_password_changeset(administrator, %{
          "current_password" => "old_password",
          "new_password" => "new_password123"
        })

      assert changeset.valid? == true
      assert Bcrypt.verify_pass("new_password123", get_change(changeset, :password_hash))
    end
  end
end
