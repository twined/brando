defmodule Brando.Migrations.MigrateTemplateWrapperCasing do
  use Ecto.Migration

  def up do
    execute """
    UPDATE
      pages_templates
    SET
      wrapper = REPLACE(
        wrapper,
        '${CONTENT}',
        '${content}'
      );
    """
  end

  def down do
    execute """
    UPDATE
      pages_templates
    SET
      wrapper = REPLACE(
        wrapper,
        '${content}',
        '${CONTENT}'
      );
    """
  end
end
