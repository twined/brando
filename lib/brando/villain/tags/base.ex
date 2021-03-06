defmodule Brando.Villain.Tags.Base do
  @moduledoc false

  import NimbleParsec
  alias Brando.Villain.Tags
  alias Liquex.Parser.Base

  @spec base_element(NimbleParsec.t()) :: NimbleParsec.t()
  def base_element(combinator \\ empty()) do
    combinator
    |> choice([
      Tags.Picture.picture_tag(),
      Tags.Route.route_tag(),
      Tags.RouteI18n.route_i18n_tag(),
      Tags.Fragment.fragment_tag(),
      Tags.Hide.hide_tag(),
      Tags.EndHide.end_hide_tag(),
      Base.base_element()
    ])
  end
end
