defmodule Brando.Blueprint.Villain.Blocks.PictureBlock do
  alias Brando.Blueprint.Villain.Blocks

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :uid, :string
    field :type, :string
    field :hidden, :boolean, default: false
    field :mark_for_deletion, :boolean, default: false, virtual: true

    embeds_one :data, Brando.Images.Image
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(uid type hidden mark_for_deletion)a)
    |> cast_embed(:data)
  end
end
