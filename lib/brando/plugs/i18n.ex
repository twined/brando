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
  def put_locale(%{private: %{plug_session: %{"language" => language}}} = conn, []) do
    language = extract_language_from_path(conn) || language
    Brando.I18n.put_locale_for_all_modules(language)
    assign_language(conn, language)
  end

  @doc """
  Add current language to `conn`.

  Adds to session and assigns, and sets it through gettext
  """
  def put_locale(conn, []) do
    language = extract_language_from_path(conn) || Brando.config(:default_language)
    Brando.I18n.put_locale_for_all_modules(language)

    conn
    |> put_language(language)
    |> assign_language(language)
  end

  @doc """
  DEPRECATED
  """
  def put_locale(_, otp_backend) do
    split_module = Module.split(otp_backend)
    use_module =
      split_module
      |> List.delete_at(Enum.count(split_module) - 1)
      |> Module.concat

    raise """
    put_locale/2 plug has been deprecated.

    Register the module through Brando.Registry in your application's startup function:

        Brando.Registry.register(#{inspect(use_module)}, [:gettext])

    """
  end

  @doc """
  Set locale to current_user's language

  This sets both Brando.Gettext (the default gettext we use in the backend),
  as well as `otp_backend` which will mostly be extra gettext from the otp
  app's backend.
  """
  def put_admin_locale(%{private: %{plug_session:
                       %{"current_user" => current_user}}} = conn, []) do
    language = Map.get(current_user, :language, Brando.config(:default_admin_language))

    # set for default brando backend
    Gettext.put_locale(Brando.Gettext, language)
    Brando.I18n.put_locale_for_all_modules(language)
    conn
  end

  @doc """
  Set default language
  """
  def put_admin_locale(conn, []) do
    assign_language(conn, Brando.config(:default_admin_language))
  end

  @doc """
  DEPRECATED
  """
  def put_admin_locale(_, otp_backend) do
    split_module = Module.split(otp_backend)
    use_module =
      split_module
      |> List.delete_at(Enum.count(split_module) - 1)
      |> Module.concat

    raise """
    put_admin_locale/2 plug has been deprecated.
    
    Register the module through Brando.Registry in your application's startup function:

        Brando.Registry.register(#{inspect(use_module)}, [:gettext])

    """
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
