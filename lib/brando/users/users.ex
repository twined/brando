defmodule Brando.Users do
  @moduledoc """
  Context for Users.
  """
  use Brando.Web, :context
  use Brando.Query
  alias Brando.Users.User
  alias Brando.Utils
  import Ecto.Query

  @type user :: User.t()

  @doc """
  Dataloader initializer
  """
  def data(_) do
    Dataloader.Ecto.new(
      Brando.repo(),
      query: &dataloader_query/2
    )
  end

  @doc """
  Dataloader queries
  """
  def dataloader_query(queryable, _), do: queryable

  query :list, User do
    fn q -> from t in q, where: is_nil(t.deleted_at) end
  end

  filters User do
    fn
      {:active, active}, q -> from t in q, where: t.active == ^active
    end
  end

  query :single, User do
    fn q -> from t in q, where: is_nil(t.deleted_at) end
  end

  matches User do
    fn
      {:id, id}, q -> from t in q, where: t.id == ^id
      {:email, email}, q -> from t in q, where: t.email == ^email
      {:active, active}, q -> from t in q, where: t.active == ^active
      {field, value}, q -> from t in q, where: field(t, ^field) == ^value
    end
  end

  mutation :create, User
  mutation :update, User
  mutation :delete, User

  @doc """
  Bumps `user`'s `last_login` to current time.
  """
  @spec set_last_login(user) :: {:ok, user}
  def set_last_login(user) do
    current_time = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
    Utils.Schema.update_field(user, last_login: current_time)
  end

  @doc """
  Set user status
  """
  def set_active(user_id, status, user) do
    update_user(user_id, %{active: status}, user)
  end

  @doc """
  Checks if `user` has access to admin area.
  """
  @spec can_login?(user) :: boolean
  def can_login?(user) do
    {:ok, role} = Brando.Type.Role.dump(user.role)
    (role > 0 && true) || false
  end
end
