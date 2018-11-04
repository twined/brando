defmodule Brando.Pages.PageResolver do
  @moduledoc """
  Resolver for Pages
  """
  use Brando.Web, :resolver
  alias Brando.Pages

  @doc """
  Find page
  """
  def find(%{page_id: page_id}, %{context: %{current_user: _current_user}}) do
    Pages.get_page(String.to_integer(page_id))
  end

  @doc """
  Get all pages (at parent level)
  """
  def all(_, %{context: %{current_user: _current_user}}) do
    Pages.list_pages()
  end

  @doc """
  Create page
  """
  def create(%{page_params: page_params}, %{context: %{current_user: current_user}}) do
    page_params
    |> Pages.create_page(current_user)
    |> response
  end

  @doc """
  Update page
  """
  def update(%{page_id: page_id, page_params: page_params}, %{
        context: %{current_user: _current_user}
      }) do
    page_id
    |> Pages.update_page(page_params)
    |> response
  end

  @doc """
  Delete page
  """
  def delete(%{page_id: page_id}, %{context: %{current_user: _current_user}}) do
    page_id
    |> Pages.delete_page()
    |> response
  end
end