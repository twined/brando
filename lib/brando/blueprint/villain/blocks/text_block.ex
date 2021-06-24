defmodule Brando.Blueprint.Villain.Blocks.TextBlock do
  defmodule Data do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false

    embedded_schema do
      field :text, :string
      field :type, Ecto.Enum, values: [:paragraph, :lede], default: :paragraph
      field :extensions, {:array, :string}
    end

    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, ~w(text type extensions)a)
    end
  end

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :uid, :string
    field :type, :string
    field :hidden, :boolean, default: false
    field :mark_for_deletion, :boolean, default: false, virtual: true
    embeds_one :data, __MODULE__.Data
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(uid type hidden mark_for_deletion)a)
    |> cast_embed(:data)
  end
end
