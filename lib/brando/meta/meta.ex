defmodule Brando.Meta do
  use Brando.Web, :schema

  @fields [:key, :value]

  embedded_schema do
    field :key
    field :value
  end

  def changeset(schema, params \\ %{}) do
    schema
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
