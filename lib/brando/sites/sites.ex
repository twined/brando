defmodule Brando.Sites do
  @moduledoc """
  Context for Sites
  """

  @type changeset :: Ecto.Changeset.t()
  @type id :: Integer.t() | String.t()
  @type identity :: Brando.Sites.Identity.t()
  @type params :: Map.t()
  @type user :: Brando.Users.User.t()

  import Ecto.Query
  alias Brando.Images
  alias Brando.Sites.Identity
  alias Brando.Villain

  @doc """
  Get identity
  """
  @spec get_identity() ::
          {:ok, identity} | {:error, {:identity, :not_found}}
  def get_identity do
    case Identity |> first() |> Brando.repo().one do
      nil -> {:error, {:identity, :not_found}}
      identity -> {:ok, identity}
    end
  end

  @doc """
  Create new identity
  """
  @spec create_identity(params, user | :system) ::
          {:ok, identity} | {:error, Ecto.Changeset.t()}
  def create_identity(identity_params, user \\ :system) do
    changeset = Identity.changeset(%Identity{}, identity_params, user)
    Brando.repo().insert(changeset)
  end

  @doc """
  Update existing identity
  """
  @spec update_identity(params, user | :system) :: {:ok, identity} | {:error, changeset}
  def update_identity(identity_params, user \\ :system) do
    {:ok, identity} = get_identity()

    identity
    |> Identity.changeset(identity_params, user)
    |> Brando.repo().update()
    |> update_cache()
    |> update_villains_referencing_org()
  end

  @doc """
  Delete identity by id
  """
  @spec delete_identity :: {:ok, identity}
  def delete_identity() do
    {:ok, identity} = get_identity()
    Brando.repo().delete(identity)
    Images.Utils.delete_original_and_sized_images(identity, :image)
    Images.Utils.delete_original_and_sized_images(identity, :logo)

    {:ok, identity}
  end

  @doc """
  Create default identity
  """
  def create_default_identity do
    %Identity{
      name: "Organisasjonens navn",
      alternate_name: "Kortversjon av navnet",
      email: "mail@domain.tld",
      phone: "+47 00 00 00 00",
      address: "Testveien 1",
      zipcode: "0000",
      city: "Oslo",
      country: "NO",
      description: "Beskrivelse av organisasjonen/nettsiden",
      title_prefix: "Firma | ",
      title: "Velkommen!",
      title_postfix: "",
      image: nil,
      logo: nil,
      url: "https://www.domain.tld"
    }
    |> Brando.repo().insert!
  end

  @doc """
  Try to get `name` from list of `links` in `identity`.
  """
  def get_link(name) do
    identity = Brando.Cache.get(:identity)
    Enum.find(identity.links, &(String.downcase(&1.name) == String.downcase(name)))
  end

  @doc """
  Check all fields for references to `["${IDENTITY:", "${CONFIG:", "${LINK:"]`.
  Rerender if found.
  """
  @spec update_villains_referencing_org({:ok, identity} | {:error, changeset}) ::
          {:ok, identity} | {:error, changeset}
  def update_villains_referencing_org({:error, changeset}), do: {:error, changeset}

  def update_villains_referencing_org({:ok, identity}) do
    search_terms = ["${IDENTITY:", "${CONFIG:", "${LINK:"]
    villains = Villain.list_villains()
    Villain.rerender_matching_villains(villains, search_terms)
    {:ok, identity}
  end

  @spec cache_identity :: {:error, boolean} | {:ok, boolean}
  def cache_identity do
    {:ok, identity} = get_identity()
    Cachex.put(:cache, :identity, identity)
  end

  @spec update_cache({:ok, identity} | {:error, changeset}) ::
          {:ok, identity} | {:error, changeset}
  def update_cache({:ok, updated_identity}) do
    Cachex.update(:cache, :identity, updated_identity)
    {:ok, updated_identity}
  end

  def update_cache({:error, changeset}), do: {:error, changeset}
end