#Code.require_file("router_helper.exs", Path.join([__DIR__, "..", ".."]))

defmodule Brando.Users.ControllerTest do
  use ExUnit.Case
  use Brando.ConnCase
  use Brando.Integration.TestCase
  use Plug.Test
  use RouterHelper
  alias Brando.User

  @params %{"avatar" => nil, "role" => ["2", "4"],
            "email" => "fanogigyni@gmail.com", "full_name" => "Nita Bond",
            "password" => "finimeze", "username" => "zabuzasixu"}

  @broken_params %{"avatar" => nil, "role" => ["2", "4"],
                   "email" => "fanogigynigmail.com", "full_name" => "Nita Bond",
                   "password" => "fi", "username" => ""}

  test "index redirects to /login when no :current_user" do
    conn = call_with_session(RouterHelper.TestRouter, :get, "/admin/brukere")
    assert redirected_to(conn, 302) =~ "/login"
  end

  test "index with logged in user" do
    conn = call_with_user(RouterHelper.TestRouter, :get, "/admin/brukere")
    assert html_response(conn, 200) =~ "Brukeroversikt"
  end

  test "show" do
    assert {:ok, user} = User.create(@params)
    conn = call_with_user(RouterHelper.TestRouter, :get, "/admin/brukere/#{user.id}")
    assert html_response(conn, 200) =~ "Nita Bond"
  end

  test "profile" do
    assert {:ok, _user} = User.create(@params)
    conn = call_with_user(RouterHelper.TestRouter, :get, "/admin/brukere/profil")
    assert html_response(conn, 200) =~ "iggypop"
  end

  test "new" do
    conn = call_with_user(RouterHelper.TestRouter, :get, "/admin/brukere/ny")
    assert html_response(conn, 200) =~ "Ny bruker"
  end

  test "edit" do
    assert {:ok, user} = User.create(@params)
    conn = call_with_user(RouterHelper.TestRouter, :get, "/admin/brukere/#{user.id}/endre")
    assert html_response(conn, 200) =~ "Endre bruker"
  end

  test "create (post) w/params" do
    conn = call_with_user(RouterHelper.TestRouter, :post, "/admin/brukere/", %{"user" => @params})
    assert redirected_to(conn, 302) =~ "/admin/brukere"
    assert get_flash(conn, :notice) == "Bruker opprettet."
  end

  test "create (post) w/erroneus params" do
    conn = call_with_user(RouterHelper.TestRouter, :post, "/admin/brukere/", %{"user" => @broken_params})
    assert html_response(conn, 200) =~ "Ny bruker"
    assert get_flash(conn, :error) == "Feil i skjema"
  end

  test "update (post) w/params" do
    assert {:ok, user} = User.create(@params)
    conn = call_with_user(RouterHelper.TestRouter, :patch, "/admin/brukere/#{user.id}", %{"user" => @params})
    assert redirected_to(conn, 302) =~ "/admin/brukere"
    assert get_flash(conn, :notice) == "Bruker oppdatert."
  end

  test "update (post) w/broken params" do
    assert {:ok, user} = User.create(@params)
    conn = call_with_user(RouterHelper.TestRouter, :patch, "/admin/brukere/#{user.id}", %{"user" => @broken_params})
    assert html_response(conn, 200) =~ "Endre bruker"
    assert get_flash(conn, :error) == "Feil i skjema"
  end

  test "delete" do
    assert {:ok, user} = User.create(@params)
    conn = call_with_user(RouterHelper.TestRouter, :delete, "/admin/brukere/#{user.id}")
    assert redirected_to(conn, 302) =~ "/admin/brukere"
  end
end