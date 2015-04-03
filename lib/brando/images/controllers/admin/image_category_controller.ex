defmodule Brando.Images.Admin.ImageCategoryController do
  @moduledoc """
  Controller for the Brando ImageCategory module.
  """
  use Phoenix.Controller

  plug :scrub_params, "imagecategory" when action in [:create, :update]
  plug :action

  @doc false
  def index(conn, _params) do
    category_model = conn.private[:category_model]
    conn
    |> assign(:categories, category_model.all)
    |> render(:index)
  end

  @doc false
  def new(conn, _params) do
    conn
    |> render(:new)
  end

  @doc false
  def create(conn, %{"imagecategory" => imagecategory}) do
    model = conn.private[:category_model]
    case model.create(imagecategory, Brando.HTML.current_user(conn)) do
      {:ok, _} ->
        conn
        |> put_flash(:notice, "Kategori opprettet.")
        |> redirect(to: router_module(conn).__helpers__.admin_image_path(conn, :index))
      {:error, errors} ->
        conn
        |> assign(:imagecategory, imagecategory)
        |> assign(:errors, errors)
        |> put_flash(:error, "Feil i skjema")
        |> render(:new)
    end
  end

  @doc false
  def delete_confirm(conn, %{"id" => id}) do
    model = conn.private[:category_model]
    record = model.get!(id: id)
    conn
    |> assign(:record, record)
    |> render(:delete_confirm)
  end

  @doc false
  def delete(conn, %{"id" => id}) do
    model = conn.private[:category_model]
    record = model.get!(id: id)
    model.delete(record)
    conn
    |> put_flash(:notice, "#{Brando.HTML.Inspect.model_name(record, :singular)} #{model.__str__(record)} slettet.")
    |> redirect(to: router_module(conn).__helpers__.admin_image_path(conn, :index))
  end
end