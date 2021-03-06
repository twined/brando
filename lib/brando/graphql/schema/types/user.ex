defmodule Brando.GraphQL.Schema.Types.User do
  use Brando.Web, :absinthe

  object :users do
    field :entries, list_of(:user)
    field :pagination_meta, non_null(:pagination_meta)
  end

  object :user do
    field :id, :id
    field :email, :string
    field :name, :string
    field :password, :string
    field :avatar, :image_type
    field :role, :string
    field :active, :boolean
    field :language, :string
    field :last_login, :time
    field :config, :user_config
    field :inserted_at, :time
    field :updated_at, :time
    field :deleted_at, :time
  end

  object :user_config do
    field :show_onboarding, :boolean
    field :show_mutation_notifications, :boolean
    field :reset_password_on_first_login, :boolean
  end

  input_object :user_config_params do
    field :show_onboarding, :boolean
    field :show_mutation_notifications, :boolean
    field :reset_password_on_first_login, :boolean
  end

  input_object :user_params do
    field :name, :string
    field :language, :string
    field :email, :string
    field :role, :string
    field :password, :string
    field :avatar, :upload_or_image
    field :active, :boolean
    field :config, :user_config_params
  end

  @desc "Filtering options for user"
  input_object :user_filter do
    field :name, :string
  end

  @desc "Matching options for user"
  input_object :user_matches do
    field :id, :id
    field :email, :string
  end

  object :user_queries do
    @desc "Get current user"
    field :me, type: :user do
      resolve &Brando.Users.UserResolver.me/2
    end

    @desc "Get all users"
    field :users, type: :users do
      arg :order, :order, default_value: [{:asc, :name}]
      arg :limit, :integer, default_value: 25
      arg :offset, :integer, default_value: 0
      arg :filter, :user_filter
      arg :status, :string
      resolve &Brando.Users.UserResolver.all/2
    end

    @desc "Get user"
    field :user, type: :user do
      arg :matches, :user_matches
      arg :revision, :id
      arg :status, :string, default_value: "all"
      resolve &Brando.Users.UserResolver.get/2
    end
  end

  object :user_mutations do
    field :create_user, type: :user do
      arg :user_params, :user_params

      resolve &Brando.Users.UserResolver.create/2
    end

    field :update_user, type: :user do
      arg :user_id, non_null(:id)
      arg :user_params, :user_params

      resolve &Brando.Users.UserResolver.update/2
    end
  end
end
