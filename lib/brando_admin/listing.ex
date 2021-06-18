defmodule BrandoAdmin.Listing do
  defmacro __using__(_) do
    quote do
      def handle_event("delete_entry", %{"id" => entry_id}, socket) do
        require Logger
        Logger.error(inspect(socket.assigns))
        {:noreply, socket}
      end
    end
  end
end