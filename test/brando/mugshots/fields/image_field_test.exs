defmodule Brando.Mugshots.Fields.ImageFieldTest do
  use ExUnit.Case, async: true
  import Brando.Mugshots.Utils

  defmodule TestModel do
    use Brando.Mugshots.Fields.ImageField

    has_image_field :avatar,
      [allowed_mimetypes: ["image/jpeg", "image/png"],
       default_size: :medium,
       upload_path: Path.join("images", "default"),
       random_filename: true,
       size_limit: 10240000,
       sizes: [
         small:  [size: "300", quality: 100],
         medium: [size: "500", quality: 100],
         large:  [size: "700", quality: 100],
         xlarge: [size: "900", quality: 100],
         thumb:  [size: "150x150^ -gravity center -extent 150x150", quality: 100, crop: true]
      ]
    ]
  end

  test "use works" do
    assert Brando.Mugshots.Fields.ImageFieldTest.TestModel.get_image_cfg(:avatar) ==
      [allowed_mimetypes: ["image/jpeg", "image/png"], default_size: :medium,
       upload_path: "images/default", random_filename: true,
       size_limit: 10240000,
       sizes: [small: [size: "300", quality: 100], medium: [size: "500", quality: 100], large: [size: "700", quality: 100],
               xlarge: [size: "900", quality: 100], thumb: [size: "150x150^ -gravity center -extent 150x150", quality: 100, crop: true]]]
  end
end