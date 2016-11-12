defmodule Brando.GuardianSerializer do
  @moduledoc """
  """
  @behaviour Guardian.Serializer

  alias Brando.User

  def for_token(user = %User{}), do: {:ok, "User:#{user.id}"}
  def for_token(_), do: {:error, "Unknown resource type"}

  def from_token("User:" <> id), do: {:ok, Brando.repo.get(User, id)}
  def from_token(_), do: {:error, "Unknown resource type"}
end