defmodule TicketBridgeWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.Flash

  def handle_error(socket, {:error, _changeset}, custom_message \\ nil) do
    error_message = custom_message || "An error occurred"
    {:noreply, socket |> put_flash(:error, error_message)}
  end
end
