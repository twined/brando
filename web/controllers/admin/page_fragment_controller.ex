defmodule Brando.Admin.PageFragmentController do
  @moduledoc """
  Controller for the Brando PageFragment module.
  """
  use Brando.Web, :controller
  use Brando.Villain.Controller,
    image_model: Brando.Image,
    series_model: Brando.ImageSeries

  import Brando.Plug.Section
  import Brando.HTML.Inspect, only: [model_name: 2]
  import Ecto.Query

  plug :put_section, "page_fragments"
  plug :scrub_params, "page_fragment" when action in [:create, :update]
  plug :action

  @doc false
  def index(conn, _params) do
    model = conn.private[:fragment_model]
    conn
    |> assign(:page_fragments, model.all)
    |> render(:index)
  end

  @doc false
  def show(conn, %{"id" => id}) do
    model = conn.private[:fragment_model]
    page =
      model
      |> preload(:creator)
      |> Brando.repo.get_by!(id: id)
    conn
    |> assign(:page_fragment, page)
    |> render(:show)
  end

  @doc false
  def new(conn, _params) do
    conn
    |> render(:new)
  end

  @doc false
  def create(conn, %{"page_fragment" => page_fragment}) do
    model = conn.private[:fragment_model]
    case model.create(page_fragment, Brando.HTML.current_user(conn)) do
      {:ok, _} ->
        conn
        |> put_flash(:notice, "Sidefragment opprettet.")
        |> redirect(to: router_module(conn).__helpers__.admin_page_fragment_path(conn, :index))
      {:error, errors} ->
        conn
        |> assign(:page_fragment, page_fragment)
        |> assign(:errors, errors)
        |> put_flash(:error, "Feil i skjema")
        |> render(:new)
    end
  end

  @doc false
  def edit(conn, %{"id" => id}) do
    model = conn.private[:fragment_model]
    page_fragment =
      model
      |> Brando.repo.get_by!(id: id)
      |> model.encode_data

    conn
    |> assign(:page_fragment, page_fragment)
    |> assign(:id, id)
    |> render(:edit)

  end

  @doc false
  def update(conn, %{"page_fragment" => form_data, "id" => id}) do
    model = conn.private[:fragment_model]
    page_fragment = model |> Brando.repo.get_by!(id: id)
    case model.update(page_fragment, form_data) do
      {:ok, _updated_page_fragment} ->
        conn
        |> put_flash(:notice, "Sidefragment oppdatert.")
        |> redirect(to: router_module(conn).__helpers__.admin_page_fragment_path(conn, :index))
      {:error, errors} ->
        conn
        |> assign(:page_fragment, form_data)
        |> assign(:errors, errors)
        |> assign(:id, id)
        |> put_flash(:error, "Feil i skjema")
        |> render(:edit)
    end
  end

  @doc false
  def delete_confirm(conn, %{"id" => id}) do
    model = conn.private[:fragment_model]
    record =
      model
      |> preload(:creator)
      |> Brando.repo.get_by!(id: id)

    conn
    |> assign(:record, record)
    |> render(:delete_confirm)
  end

  @doc false
  def delete(conn, %{"id" => id}) do
    model = conn.private[:fragment_model]
    record = model |> Brando.repo.get_by!(id: id)
    model.delete(record)
    conn
    |> put_flash(:notice, "#{model_name(record, :singular)} #{model.__repr__(record)} slettet.")
    |> redirect(to: router_module(conn).__helpers__.admin_page_fragment_path(conn, :index))
  end
end