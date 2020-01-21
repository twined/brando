defmodule Brando.Images.ImageResolver do
  @moduledoc """
  Resolver for image categories
  """
  use Brando.Web, :resolver
  alias Brando.Images

  @doc """
  Create image
  """
  def create(%{image_series_id: series_id, image_upload_params: %{image: image}}, %{
        context: %{current_user: current_user}
      }) do
    {:ok, cfg} = Images.get_series_config(series_id)
    Images.Uploads.Schema.handle_upload(%{
      "image" => image,
      "image_series_id" => series_id
    }, cfg, current_user)
    |> List.first
    |> response
  end

  @doc """
  Delete images
  """
  def delete_images(%{image_ids: image_ids}, %{context: %{current_user: _current_user}}) do
    #! TODO - check permissios
    Images.delete_images(image_ids)
    {:ok, 200}
  end
end