defmodule Brando.Integration.ImageCategoryTest do
  use ExUnit.Case
  use Brando.ConnCase
  use Brando.Integration.TestCase
  alias Brando.Factory

  setup do
    user = Factory.insert(:user)
    category = Factory.insert(:image_category, creator: user)
    series = Factory.insert(:image_series, creator: user, image_category: category)
    {:ok, %{user: user, category: category, series: series}}
  end
end