defmodule Brando.Files.Upload do
  @moduledoc """
  Processing function for file uploads.
  """
  alias Brando.Images
  alias Brando.Upload
  import Brando.Utils

  @doc """
  Creates a File{} struct pointing to the copied uploaded file.
  """
  @spec create_file_struct(Brando.Upload.t()) :: {:ok, Brando.Type.File.t()}
  def create_file_struct(%Upload{plug: %{uploaded_file: file, content_type: mime_type}, cfg: cfg}) do
    {_, filename} = split_path(file)
    upload_path = Map.get(cfg, :upload_path)

    file_path = Path.join([upload_path, filename])

    file_stat =
      file_path
      |> Images.Utils.media_path()
      |> File.stat!()

    file_struct =
      %Brando.Type.File{}
      |> Map.put(:path, file_path)
      |> Map.put(:size, file_stat.size)
      |> Map.put(:mimetype, mime_type)

    {:ok, file_struct}
  end
end
