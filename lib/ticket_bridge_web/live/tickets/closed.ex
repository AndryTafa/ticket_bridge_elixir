defmodule TicketBridgeWeb.Tickets.Closed do
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
      id="closed-tickets"
      title="Closed Tickets"
      status={:closed}
      page_path={tickets_closed_path()}
      current_user={@current_user}
      page={@page}
    />
    """
  end
end
