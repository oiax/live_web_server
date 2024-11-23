defmodule LiveWebServer.CoreTest do
  use ExUnit.Case
  alias LiveWebServer.Core

  describe "change_my_password/3" do
    setup do
      administrator = %Core.Administrator{
        id: 1,
        password_hash: Bcrypt.hash_pwd_salt("current_password")
      }

      {:ok, administrator: administrator}
    end

    test "successfully changed password", %{administrator: administrator} do
      current_password = "current_password"
      new_password = "new_password123"

      assert {:ok, _administrator} =
               Core.change_my_password(administrator, current_password, new_password)
    end

    test "current password is incorrect", %{administrator: administrator} do
      current_password = "incorrect_password"
      new_password = "new_password123"

      assert {:error, :worng_password} =
               Core.change_my_password(administrator, current_password, new_password)
    end

    test "short password", %{administrator: administrator} do
      current_password = "current_password"
      new_password = "1"

      assert {:error, :short_password} =
               Core.change_my_password(administrator, current_password, new_password)
    end

    test "borderline password", %{administrator: administrator} do
      current_password = "current_password"
      new_password = "1234567"

      assert {:error, :short_password} =
               Core.change_my_password(administrator, current_password, new_password)
    end
  end
end
