defmodule Brando.Schema.Types.Identity do
  @moduledoc """
  GraphQL type spec, mutations and queries for Identity
  """
  use Brando.Web, :absinthe

  object :identity do
    field :id, :id
    field :type, :string
    field :name, :string
    field :alternate_name, :string
    field :email, :string
    field :phone, :string
    field :address, :string
    field :zipcode, :string
    field :city, :string
    field :country, :string
    field :description, :string
    field :title_prefix, :string
    field :title, :string
    field :title_postfix, :string
    field :image, :image_type
    field :logo, :image_type
    field :url, :string
    field :links, list_of(:link), resolve: dataloader(Brando.Sites)
    field :metas, list_of(:meta), resolve: dataloader(Brando.Sites)
    field :configs, list_of(:config), resolve: dataloader(Brando.Sites)
    field :inserted_at, :time
    field :updated_at, :time
  end

  object :link do
    field :id, :id
    field :name, :string
    field :url, :string
  end

  object :meta do
    field :id, :id
    field :key, :string
    field :value, :string
  end

  object :config do
    field :id, :id
    field :key, :string
    field :value, :string
  end

  input_object :identity_params do
    field :type, :string
    field :name, :string
    field :alternate_name, :string
    field :email, :string
    field :phone, :string
    field :address, :string
    field :zipcode, :string
    field :city, :string
    field :country, :string
    field :description, :string
    field :title_prefix, :string
    field :title, :string
    field :title_postfix, :string
    field :links, list_of(:link_params)
    field :metas, list_of(:meta_params)
    field :configs, list_of(:config_params)
    field :image, :upload_or_image
    field :logo, :upload_or_image
    field :url, :string
  end

  input_object :link_params do
    field :id, :id
    field :name, :string
    field :url, :string
  end

  input_object :meta_params do
    field :id, :id
    field :key, :string
    field :value, :string
  end

  input_object :config_params do
    field :id, :id
    field :key, :string
    field :value, :string
  end

  object :identity_queries do
    @desc "Get identity"
    field :identity, type: :identity do
      resolve &Brando.Sites.IdentityResolver.get/2
    end
  end

  object :identity_mutations do
    field :create_identity, type: :identity do
      arg :identity_params, non_null(:identity_params)
      resolve &Brando.Sites.IdentityResolver.create/2
    end

    field :update_identity, type: :identity do
      arg :identity_params, :identity_params
      resolve &Brando.Sites.IdentityResolver.update/2
    end

    field :delete_identity, type: :identity do
      resolve &Brando.Sites.IdentityResolver.delete/2
    end
  end
end
