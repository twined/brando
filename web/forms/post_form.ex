defmodule Brando.PostForm do
  @moduledoc """
  A form for the Post model. See the `Brando.Form` module for more
  documentation
  """
  use Brando.Form

  @doc false
  def get_language_choices do
    Brando.config(:languages)
  end

  @doc false
  def get_status_choices do
    Brando.config(:status_choices)
  end

  @doc """
  Check is status' choice is selected.
  Translates the `model_value` from an atom to an int as string
  through `Brando.Type.Status.dump/1`.
  Returns boolean.
  """
  @spec is_status_selected?(String.t, atom) :: boolean
  def is_status_selected?(form_value, model_value) do
    # translate value from atom to corresponding int as string
    {:ok, status_int} = Brando.Type.Status.dump(model_value)
    form_value == to_string(status_int)
  end

  form "post", [helper: :admin_post_path, class: "grid-form"] do
    fieldset do
      field :language, :select,
        [required: true,
        label: "Språk",
        default: "no",
        choices: &__MODULE__.get_language_choices/0]
    end
    fieldset do
      field :status, :radio,
        [required: true,
        label: "Status",
        default: "2",
        choices: &__MODULE__.get_status_choices/0,
        is_selected: &__MODULE__.is_status_selected?/2]
    end
    fieldset do
      field :featured, :checkbox,
        [label: "Vektet post",
        default: false,
        help_text: "Posten vektes uavhengig av opprettelses- og publiseringsdato"]
    end
    fieldset do
      field :header, :text,
        [required: true,
         label: "Overskrift",
         placeholder: "Overskrift"]
      field :slug, :text,
        [required: true,
         label: "URL-tamp",
         placeholder: "URL-tamp",
         slug_from: :header]
    end
    field :lead, :textarea,
      [label: "Ingress"]
    field :data, :textarea,
      [label: "Innhold"]
    field :publish_at, :text,
      [required: true,
       label: "Publiseringstidspunkt",
       default: &Brando.Utils.get_now/0]
    field :tags, :text,
      [label: "Tags",
       tags: true]
    submit "Lagre",
      [class: "btn btn-success"]
  end
end