defmodule TicketBridgeWeb.Helpers.PathHelpers do
  # Static paths
  def dashboard_path, do: "/app/dashboard"
  def tickets_pending_path, do: "/app/tickets/pending"
  def tickets_closed_path, do: "/app/tickets/closed"

  def user_settings_path, do: "/app/users/settings"
  def user_log_out_url, do: "/users/log_out"

  # Dynamic paths
  def ticket_path(ticket_id) when is_binary(ticket_id) or is_integer(ticket_id) do
    "/app/tickets/#{ticket_id}"
  end
end
