defmodule Brando.Images.Operations do
  @moduledoc """
  This is where we process images
  """
  require Logger

  alias Brando.Images
  alias Brando.Progress
  alias Brando.Utils

  @type image_type_struct :: Brando.Type.Image.t()
  @type image_config :: Brando.Type.ImageConfig.t()
  @type operation :: Brando.Images.Operation.t()
  @type operation_result :: Brando.Images.OperationResult.t()
  @type user :: Brando.Users.User.t() | :system

  @doc """
  Creates an %Operation{} for each size key in `cfg`s `:sizes`

  ## Example

      {:ok, operations} = create(image_struct, img_cfg, id, user)

  """
  @spec create(
          image_type_struct :: image_type_struct,
          cfg :: image_config,
          id :: integer | nil,
          user :: user
        ) :: {:ok, [operation]}
  def create(%{path: path} = image_struct, cfg, id, user) do
    id = id || Utils.random_string(:os.timestamp())
    {_, filename} = Utils.split_path(path)
    type = cfg.target_format || Images.Utils.image_type(path)

    total_operations =
      Map.get(cfg, :sizes)
      |> Map.keys()
      |> Enum.count()

    operations =
      for {{size_key, size_cfg}, idx} <- Enum.with_index(Map.get(cfg, :sizes)) do
        sized_image_dir = Images.Utils.get_sized_dir(path, size_key)
        sized_image_path = Images.Utils.get_sized_path(path, size_key, type)

        %Images.Operation{
          id: id,
          type: type,
          user: user,
          filename: filename,
          image_struct: image_struct,
          size_cfg: size_cfg,
          size_key: size_key,
          sized_image_dir: sized_image_dir,
          sized_image_path: sized_image_path,
          total_operations: total_operations,
          operation_index: idx + 1
        }
      end

    {:ok, operations}
  end

  @doc """
  Perform list of image operations as Flow
  """
  @spec perform(operations :: [operation], user :: user) :: {:ok, [operation_result]}
  def perform(operations, user) do
    Progress.show_progress(user)

    Logger.info("""
    ==> Brando.Images.Operations: Starting #{Enum.count(operations)} operations..
    """)

    start_msec = :os.system_time(:millisecond)

    operation_results =
      operations
      |> Flow.from_enumerable()
      |> Flow.partition(stages: 1, hash: fn e -> e.key end)
      |> Flow.map(&resize_image/1)
      |> Flow.reduce(fn -> %{} end, fn operation, map ->
        Map.update(map, operation.id, [operation], &[operation | &1])
      end)
      |> Flow.departition(&Map.new/0, &Map.merge(&1, &2, fn _, la, lb -> la ++ lb end), & &1)
      |> Enum.map(fn result -> compile_transform_results(result, operations) end)
      |> List.flatten()

    end_msec = :os.system_time(:millisecond)

    seconds_lapsed = (end_msec - start_msec) * 0.001

    Logger.info("""
    ==> Brando.Images.Operations: Finished in #{seconds_lapsed} seconds..
    """)

    Progress.hide_progress(user)

    {:ok, operation_results}
  end

  # assemble all `%TransformResult{}`s for each id
  defp compile_transform_results(transform_results, operations) do
    for {key, transforms} <- transform_results do
      operation = get_operation_by_key(key, operations)
      image_struct = %{operation.image_struct | sizes: transforms_to_sizes(transforms)}

      %Images.OperationResult{
        id: key,
        image_struct: image_struct
      }
    end
  end

  # convert a list of transforms to a map of sizes
  defp transforms_to_sizes(transforms) do
    transforms
    |> Enum.map(&{&1.size_key, &1.image_path})
    |> Enum.into(%{})
  end

  defp get_operation_by_key(key, operations), do: Enum.find(operations, &(&1.id == key))

  defp resize_image(%Images.Operation{} = operation),
    do: Images.Operations.Sizing.create_image_size(operation) |> elem(1)
end
