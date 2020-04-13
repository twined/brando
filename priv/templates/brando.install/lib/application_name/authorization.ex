defmodule <%= application_module %>.Authorization do
  @moduledoc """
  Authorization module for application.

  This module sets permissions across the application on the backend
  as well as the frontend.
  """

  use Brando.Authorization

  # Declare types so we can translate seamlessly between
  # frontend and backend authorization queries.
  types [
    {"Identity", Brando.Sites.Identity},
    {"Image", Brando.Image},
    {"ImageSeries", Brando.ImageSeries},
    {"ImageCategory", Brando.ImageCategory},
    {"Page", Brando.Pages.Page},
    {"PageFragment", Brando.Pages.PageFragment},
    {"Template", Brando.Villain.Template},
    {"User", Brando.Users.User},
  ]

  # Rules for :superuser
  rules :superuser do
    can :manage, :all
  end

  # Rules for :admin
  rules :admin do
    can :manage, :all
    cannot :manage, %Brando.Users.User{}, when: %{role: "superuser"}
    cannot :view, "MenuItem", when: %{to: %{name: "templates"}}
  end

  # Rules for :editor
  rules :editor do
    can :manage, :all
    cannot :manage, "Globals"
    cannot :manage, %Brando.Sites.Identity{}
    cannot :manage, %Brando.Villain.Template{}
    cannot :manage, %Brando.Users.User{}
    cannot :view, "MenuItem", when: %{to: %{name: "config-identity"}}
    cannot :view, "MenuItem", when: %{to: %{name: "config-globals"}}
    cannot :view, "MenuItem", when: %{to: %{name: "templates"}}
    cannot :view, "MenuItem", when: %{to: %{name: "users"}}
  end

  # Rules for :user
  rules :user do
    cannot :manage, :all
  end
end