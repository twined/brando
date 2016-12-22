defmodule Brando.SessionController do
  @moduledoc """
  Controller for authentication actions.
  """

  use Brando.Web, :controller
  alias Brando.{User, Users}
  import Brando.Gettext

  @default_auth_sleep_duration 2500

  @doc false
  def login(conn, %{"user" => %{"email" => email, "password" => password}}) do
    user = Users.get_user_by(email: email)

    if User.auth?(user, password) do
      user = Users.set_last_login(user)

      conn
      |> sleep()
      |> Guardian.Plug.sign_in(user)
      |> redirect(to: "/admin")
    else
      conn
      |> sleep()
      |> put_flash(:error, gettext("Authorization failed"))
      |> redirect(to: "/auth/login")
    end
  end

  @doc false
  def login(conn, _params) do
    conn
    |> assign(:type, "HELLO!")
    |> put_layout({Brando.Session.LayoutView, "auth.html"})
    |> render(:login)
  end

  @doc false
  def logout(conn, _params) do
    conn
    |> assign(:type, "GOODBYE!")
    |> put_layout({Brando.Session.LayoutView, "auth.html"})
    |> Guardian.Plug.sign_out()
    |> render(:logout)
  end

  defp sleep(conn) do
    :timer.sleep(Brando.config(:auth_sleep_duration) || @default_auth_sleep_duration)
    conn
  end
end