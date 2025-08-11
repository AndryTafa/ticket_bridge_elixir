defmodule TicketBridgeWeb.Tickets.Pending do
  alias TicketBridgeWeb.Helpers.PathHelpers
  use TicketBridgeWeb, :live_view
  import PathHelpers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page: 1)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    {:noreply, assign(socket, page: page)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component
      module={TicketBridgeWeb.Components.TicketTable}
      id="pending-tickets"
      title="Pending Tickets"
      status={:pending}
      page_path={tickets_pending_path()}
      current_user={@current_user}
      page={@page}
    />
    """
  end
end
