defmodule Brando.ImageSeriesForm do
  @moduledoc """
  A form for the ImageCategory model. See the `Brando.Form` module for more
  documentation
  """
  use Brando.Form
  alias Brando.ImageCategory

  @doc false
  def get_categories do
    cats = ImageCategory |> ImageCategory.with_image_series_and_images |> Brando.repo.all
    for cat <- cats, do: [value: cat.id, text: cat.name]
  end

  form "imageseries", [helper: :admin_image_series_path, class: "grid-form"] do
    fieldset do
      field :image_category_id, :radio,
        [required: true,
         label: "Kategori",
         choices: &__MODULE__.get_categories/0]
    end
    field :name, :text,
      [required: true,
       label: "Navn",
       placeholder: "Navn"]
    field :slug, :text,
      [required: true,
       label: "URL-tamp",
       placeholder: "URL-tamp",
       slug_from: :name]
    field :credits, :text,
      [required: false,
       label: "Kreditering",
       placeholder: "Kreditering"]
    submit "Lagre",
      [class: "btn btn-success"]
  end
end