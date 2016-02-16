defmodule Brando.Plug.I18n do
  @moduledoc """
  A plug for checking i18n
  """
  import Brando.I18n

  @doc """
  Assign current language.

  Here it already is in `conn`'s session, so we set it through Gettext as
  well as assigning.
  """
  def put_locale(%{private: %{plug_session: %{"language" => language}}} = conn, backend) do
    language = extract_language_from_path(conn) || language
    Gettext.put_locale(backend, language)
    assign_language(conn, language)
  end

  @doc """
  Add current language to `conn`.

  Adds to session and assigns, and sets it through gettext
  """
  def put_locale(conn, backend) do
    language = extract_language_from_path(conn)
               || Brando.config(:default_language)
    Gettext.put_locale(backend, language)

    conn
    |> put_language(language)
    |> assign_language(language)
  end

  @doc """
  Set locale to current_user's language

  This sets both Brando.Gettext (the default gettext we use in the backend),
  as well as `otp_backend` which will mostly be extra gettext from the otp
  app's backend.
  """
  def put_admin_locale(conn, otp_backend \\ nil)
  def put_admin_locale(%{private: %{plug_session:
                       %{"current_user" => current_user}}} = conn, otp_backend) do
    language = Map.get(current_user, :language, Brando.config(:default_admin_language))

    # set for default brando backend
    Gettext.put_locale(Brando.Gettext, language)

    # set locale for all registered modules
    modules = Brando.Registry.gettext_modules()
    for module <- modules do
      Gettext.put_locale(module, language)
    end

    # set for otp app's backend
    if otp_backend, do:
      Gettext.put_locale(otp_backend, language)
    conn
  end

  @doc """
  Set default language
  """
  def put_admin_locale(conn, _) do
    assign_language(conn, Brando.config(:default_admin_language))
  end

  defp extract_language_from_path(conn) do
    lang = List.first(conn.path_info)
    if lang do
      langs =
        :languages
        |> Brando.config
        |> List.flatten
        |> Keyword.get_values(:value)

      if lang in langs, do: lang
    end
  end
end
