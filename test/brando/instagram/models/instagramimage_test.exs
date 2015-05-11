defmodule Brando.Integration.InstagramImageTest do
  use ExUnit.Case
  use Brando.ConnCase
  use Brando.Integration.TestCase
  alias Brando.InstagramImage

  @params %{"approved" => true, "caption" => "Image caption",
            "created_time" => "1412469138", "deleted" => false,
            "instagram_id" => "000000000000000000_000000",
            "link" => "https://instagram.com/p/dummy_link/", "type" => "image",
            "url_original" => "https://scontent.cdninstagram.com/0.jpg",
            "url_thumbnail" => "https://scontent.cdninstagram.com/0.jpg",
            "username" => "dummyuser"}

  test "create/1 and update/1" do
    assert {:ok, img} = InstagramImage.create(@params)
    assert {:ok, updated_img} = InstagramImage.update(img, %{"caption" => "New caption"})
    assert updated_img.caption == "New caption"
  end

  test "create/1 errors" do
    {_v, params} = Dict.pop @params, "caption"
    assert {:error, err} = InstagramImage.create(params)
    assert err == [caption: "can't be blank"]
  end

  test "get/1" do
    assert {:ok, img} = InstagramImage.create(@params)
    assert InstagramImage.get(id: img.id) == img
  end

  test "get!/1" do
    assert {:ok, img} = InstagramImage.create(@params)
    assert InstagramImage.get!(id: img.id) == img
  end

  test "delete/1" do
    assert {:ok, img} = InstagramImage.create(@params)
    InstagramImage.delete(img)
    assert InstagramImage.get(id: img.id) == nil

    assert {:ok, img} = InstagramImage.create(@params)
    InstagramImage.delete(img.id)
    assert InstagramImage.get(id: img.id) == nil
  end
end