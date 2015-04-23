defmodule Brando do
  @moduledoc """
  Brando is a set of helping hands for building Twined applications.
  """

  @doc """
  Gets the configuration for `module` under :brando,
  as set in config.exs
  """
  def config(module), do: Application.get_env(:brando, module)

  @doc """
  Gets the parent app's router, as set in config.exs
  """
  def get_router, do: config(:router)

  @doc """
  Gets the parent app's endpoint, as set in config.exs
  """
  def get_endpoint, do: config(:endpoint)

  @doc """
  Gets the parent app's repo, as set in config.exs
  """
  def repo do
    config(:repo)
  end

  @doc """
  Gets the parent app's helpers, as set in config.exs
  """
  def get_helpers do
    config(:helpers)
  end
end