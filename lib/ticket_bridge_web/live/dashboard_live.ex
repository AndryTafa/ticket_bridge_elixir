defmodule TicketBridgeWeb.DashboardLive do
  alias TicketBridgeWeb.Helpers.PathHelpers
  use TicketBridgeWeb, :live_view
  import PathHelpers

  @impl true
  def mount(_params, _session, socket) do
    socket = socket
      |> assign(:return_to, "/app/dashboard")
      |> assign(:page, 1)
    {:ok, socket}
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
      id="active-tickets"
      title="Active Tickets"
      status={:open}
      page_path={dashboard_path()}
      current_user={@current_user}
      page={@page}
    />
    """
  end
end
