defmodule Brando.InstagramImage do
  @moduledoc """
  Ecto schema for the InstagramImage model
  and helper functions for dealing with the model.
  """
  @type t :: %__MODULE__{}

  use Brando.Web, :model
  require Logger
  import Ecto.Query, only: [from: 2]
  alias Brando.Instagram

  @cfg Application.get_env(:brando, Brando.Instagram)

  @required_fields ~w(instagram_id caption link url_original username
                      url_thumbnail created_time type status)
  @optional_fields ~w(image)

  schema "instagramimages" do
    field :instagram_id, :string
    field :type, :string
    field :caption, :string
    field :link, :string
    field :username, :string
    field :url_original, :string
    field :url_thumbnail, :string
    field :image, Brando.Type.Image
    field :created_time, :string
    field :status, Brando.Type.InstagramStatus, default: :rejected
  end

  @doc """
  Casts and validates `params` against `model` to create a valid
  changeset when action is :create.

  ## Example

      model_changeset = changeset(%__MODULE__{}, :create, params)

  """
  @spec changeset(t, atom, Keyword.t | Options.t) :: t
  def changeset(model, :create, params) do
    status = if @cfg[:auto_approve], do: :approved, else: :rejected
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_unique(:instagram_id, on: Brando.repo)
    |> put_change(:status, status)
  end

  @doc """
  Casts and validates `params` against `model` to create a valid
  changeset when action is :update.

  ## Example

      model_changeset = changeset(%__MODULE__{}, :update, params)

  """
  @spec changeset(t, atom, %{binary => term} | %{atom => term}) :: t
  def changeset(model, :update, params) do
    model
    |> cast(params, [], @required_fields ++ @optional_fields)
  end

  @doc """
  Create a changeset for the model by passing `params`.
  If not valid, return errors from changeset
  """
  @spec create(%{binary => term} | %{atom => term}) :: {:ok, t} | {:error, Keyword.t}
  def create(params) do
    model_changeset = %__MODULE__{} |> changeset(:create, params)
    case model_changeset.valid? do
      true ->  {:ok, Brando.repo.insert!(model_changeset)}
      false -> {:error, model_changeset.errors}
    end
  end

  @doc """
  Create an `update` changeset for the model by passing `params`.
  If valid, update model in Brando.repo.
  If not valid, return errors from changeset
  """
  @spec update(t, %{binary => term} | %{atom => term}) :: {:ok, t} | {:error, Keyword.t}
  def update(model, params) do
    model_changeset = model |> changeset(:update, params)
    case model_changeset.valid? do
      true ->  {:ok, Brando.repo.update!(model_changeset)}
      false -> {:error, model_changeset.errors}
    end
  end

  @doc """
  Takes a map provided from the API and transforms it to a map we can
  use to store in the DB.
  """
  def store_image(%{"id" => instagram_id, "caption" => caption, "user" => user,
                    "images" => %{"thumbnail" => %{"url" => thumb}, "standard_resolution" => %{"url" => org}}} = image) do
    image
    |> Map.merge(%{"username" => user["username"], "instagram_id" => instagram_id,
                   "caption" => (if caption, do: caption["text"], else: ""),
                   "url_thumbnail" => thumb, "url_original" => org})
    |> Map.drop(["images", "id"])
    |> download_image
    |> create_image_sizes
    |> create
  end

  defp download_image(image) do
    image_field = %Brando.Type.Image{}
    url = Map.get(image, "url_original")
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{body: body}} ->
        media_path = Brando.config(:media_path)
        instagram_path = Instagram.config(:upload_path)
        path = Path.join([media_path, instagram_path])
        case File.mkdir_p(path) do
          :ok ->
            file = Path.join([path, Path.basename(url)])
            File.write!(file, body)
            image_field = Map.put(image_field, :path, Path.join([instagram_path, Path.basename(url)]))
            Map.put(image, "image", image_field)
          {:error, reason} ->
            raise UploadError, message: "Kunne ikke lage filbane -> #{inspect(reason)}"
        end
      {:error, err} ->
        {:error, err}
    end
  end

  defp create_image_sizes(image_model) do
    sizes_cfg = Brando.Instagram.config(:sizes)
    if sizes_cfg != nil do
      image_field = image_model["image"]
      media_path = Brando.config(:media_path)

      full_path = Path.join([media_path, image_field.path])
      {file_path, filename} = Brando.Utils.split_path(full_path)

      sizes = for {size_name, size_cfg} <- sizes_cfg do
        size_dir = Path.join([file_path, to_string(size_name)])
        File.mkdir_p(size_dir)
        sized_image = Path.join([size_dir, filename])
        Brando.Images.Utils.create_image_size(full_path, sized_image, size_cfg)
        sized_path = Path.join([Brando.Instagram.config(:upload_path), to_string(size_name), filename])
        {size_name, sized_path}
      end
      image_field = image_field |> Map.put(:sizes, Enum.into(sizes, %{}))
      Map.put(image_model, "image", image_field)
    else
      image_model
    end

  end

  @doc """
  Get timestamp from where we search for new images
  """
  def get_last_created_time do
    max =
      from(m in __MODULE__,
           select: m.created_time,
           order_by: [desc: m.created_time],
           limit: 1)
      |> Brando.repo.one
    case max do
      nil -> ""
      max -> max
             |> String.to_integer
             |> Kernel.+(1)
             |> Integer.to_string
    end
  end

  @doc """
  Get min_id from where we search for new images
  """
  def get_min_id do
    id =
      from(m in __MODULE__,
           select: m.instagram_id,
           order_by: [desc: m.instagram_id],
           limit: 1)
      |> Brando.repo.one
    case id do
      nil -> ""
      id -> Enum.at(String.split(id, "_"), 0)
    end
  end

  @doc false
  defmacro update_all(queryable, values, opts \\ []) do
    Ecto.Repo.Queryable.update_all(Brando.repo, Ecto.Adapters.Postgres, queryable, values, opts)
  end

  def change_status_for(ids, status)
      when is_list(ids)
      and status in ["0", "1", "2"] do
    ids = ids |> Enum.map(fn(id) -> String.to_integer(id) end)
    q = from(m in __MODULE__, where: m.id in ^ids)
    update_all(q, status: ^status)
  end

  @doc """
  Delete `record` from database

  Also deletes all dependent image sizes.
  """
  def delete(ids) when is_list(ids) do
    for id <- ids, do:
      delete(id)
  end

  def delete(record) when is_map(record) do
    Brando.repo.delete!(record)
  end

  def delete(id) do
    record = Brando.repo.get_by!(__MODULE__, id: id)
    delete(record)
  end

  #
  # Meta

  use Brando.Meta,
    [singular: "instagrambilde",
     plural: "instagrambilder",
     repr: &("#{&1.id} | #{&1.caption}"),
     fields: [id: "ID",
              instagram_id: "Instagram ID",
              type: "Type",
              caption: "Tittel",
              link: "Link",
              url_original: "Bilde-URL",
              url_thumbnail: "Miniatyrbilde-URL",
              created_time: "Opprettet",
              status: "Status"]]

end