defmodule Brando.Utils.Schema do
  @moduledoc """
  Common schema utility functions
  """

  @slug_collision_attemps 15

  @doc """
  Updates a field on `schema`.
  `coll` should be [field_name: value]

  ## Example:

      {:ok, schema} = update_field(schema, [field_name: "value"])

  """

  def update_field(schema, coll) do
    changeset = Ecto.Changeset.change(schema, coll)
    {:ok, Brando.repo.update!(changeset)}
  end

  @doc """
  Puts `id` from `user` in the `params` map.
  """
  def put_creator(params, user) do
    key = is_atom(List.first(Map.keys(params))) && :creator_id || "creator_id"
    Map.put(params, key, user.id)
  end

  @doc """
  Precheck :slug in `cs` to make sure we avoid collisions
  """
  def avoid_slug_collision(cs) do
    module = cs.data.__struct__
    slug = Ecto.Changeset.get_change(cs, :slug)
    if slug do
      unique_slug =
        case get_unique_slug(module, slug, 0) do
          {:ok, unique_slug} -> unique_slug
          {:error, :too_many_attempts} -> slug
        end
      Ecto.Changeset.put_change(cs, :slug, unique_slug)
    else
      cs
    end
  end

  defp get_unique_slug(module, slug, attempts) when attempts < @slug_collision_attemps do
    slug_to_test = construct_slug(slug, attempts)
    case Brando.repo.get_by(module, slug: slug_to_test) do
      nil -> {:ok, slug_to_test}
      _   -> get_unique_slug(module, slug, attempts + 1)
    end
  end

  defp get_unique_slug(_, _, _) do
    {:error, :too_many_attempts}
  end

  defp construct_slug(slug, 0) do
    slug
  end

  defp construct_slug(slug, attempts) do
    "#{slug}-#{to_string(attempts)}"
  end
end