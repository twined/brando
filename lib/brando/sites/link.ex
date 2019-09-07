defmodule Brando.Link do
  use Brando.Web, :schema

  @fields [:name, :url]

  embedded_schema do
    field :name
    field :url
  end

  def changeset(schema, params \\ %{}) do
    schema
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
