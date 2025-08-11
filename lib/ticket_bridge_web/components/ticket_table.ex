defmodule TicketBridgeWeb.Components.TicketTable do
  use TicketBridgeWeb, :live_component
  import SaladUI.Table
  import SaladUI.Pagination
  import SaladUI.Tooltip
  alias TicketBridgeWeb.Helpers.PathHelpers
  alias TicketBridge.Ticket
  import PathHelpers

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:per_page, 5)
      |> fetch_tickets()

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-semibold text-gray-900"><%= @title %></h1>
      </div>
      <div class="border rounded-lg overflow-hidden">
        <.table class="w-full table-fixed">
          <.table_caption class="sr-only"><%= @title %></.table_caption>
          <.table_header class="bg-gray-50">
            <.table_row>
              <.table_head class="w-[100px] py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900">ID</.table_head>
              <.table_head class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Subject</.table_head>
              <.table_head class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Status</.table_head>
              <.table_head class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Priority</.table_head>
              <.table_head class="relative py-3.5 pl-3 pr-4 text-right">
                <div class="inline-block relative group">
                  <div class="px-4 cursor-help">?</div>
                  <div class="absolute right-0 z-50 hidden group-hover:block bg-primary text-white p-2 rounded shadow-lg whitespace-nowrap mt-1">
                    <p>Tickets are sorted by highest priority first, and then creation date.</p>
                  </div>
                </div>
              </.table_head>
            </.table_row>
          </.table_header>
          <.table_body class="divide-y divide-gray-200 bg-white">
            <%= if length(@tickets) == 0 do %>
              <.table_row>
              <.table_cell colspan="5" class="py-4">
              <div class="flex flex-col items-center justify-center py-12 px-4">
              <div class="bg-gray-100 rounded-full p-3 mb-4">
              <svg 
              class="w-8 h-8 text-gray-400" 
              viewBox="0 0 24 24" 
              fill="none" 
              stroke="currentColor" 
              stroke-width="2"
              >
              <rect x="3" y="5" width="18" height="14" rx="2" />
              <path d="M3 7l9 6 9-6" />
              </svg>
              </div>
              <h3 class="text-lg font-medium text-gray-900 mb-1">
              No tickets found
              </h3>
              <p class="text-sm text-gray-500 text-center max-w-sm">
              There are currently no tickets in this view. New tickets will appear here when they are created.
              </p>
              </div>
              </.table_cell>
              </.table_row>
              <% else %>
              <%= for ticket <- @tickets do %>
                <.table_row class="hover:bg-gray-50">
                <.table_cell class="truncate py-4 pl-4 pr-3 text-sm font-medium text-gray-900"><%= ticket.user_ticket_number %></.table_cell>
                <.table_cell class="truncate px-3 py-4 text-sm text-gray-900"><%= ticket.subject %></.table_cell>
                <.table_cell class="truncate px-3 py-4 text-sm text-gray-500"><%= ticket.status %></.table_cell>
                <.table_cell class="truncate px-3 py-4 text-sm text-gray-500"><%= ticket.priority %></.table_cell>
                <.table_cell class="truncate py-4 pl-3 pr-4 text-right text-sm font-medium">
                <.link navigate={ticket_path(ticket.id)} class="inline-flex">
                <SaladUI.Button.button class="text-sm" size="sm">View</SaladUI.Button.button>
                </.link>
                </.table_cell>
                </.table_row>
                <% end %>
              <%= if length(@tickets) < 5 do %>
                <%= for _i <- length(@tickets)..(5 - 1) do %>
                  <.table_row class="hover:bg-white">
                  <.table_cell class="whitespace-nowrap py-4 pl-4 pr-3 text-sm">&nbsp;</.table_cell>
                  <.table_cell class="whitespace-nowrap px-3 py-4 text-sm">&nbsp;</.table_cell>
                  <.table_cell class="whitespace-nowrap px-3 py-4 text-sm">&nbsp;</.table_cell>
                  <.table_cell class="whitespace-nowrap px-3 py-4 text-sm">&nbsp;</.table_cell>
                  <.table_cell class="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium">
                  <div class="invisible inline-flex">
                  <SaladUI.Button.button class="text-sm" size="sm">View</SaladUI.Button.button>
                  </div>
                  </.table_cell>
                  </.table_row>
                  <% end %>
                <% end %>
              <% end %>
          </.table_body>
        </.table>
        <!-- Navigation Buttons -->
        <div class="flex items-center justify-between border-t border-gray-200 bg-white px-4 py-3 sm:px-6">
          <p class="text-sm text-gray-700">
            Page <%= @page_number %> of <%= @total_pages %>
          </p>

          <div class="flex gap-1 items-center">
            <.pagination_link 
              navigate={uri(@page_path, %{page: @page_number - 1})} 
              class={if @page_number == 1, do: "pointer-events-none", else: ""}>
              &lt;
            </.pagination_link>
            <.pagination_link 
              navigate={uri(@page_path, %{page: 1})} 
              class={if @page_number == 1, do: "pointer-events-none", else: ""}>
              &lt;&lt;
            </.pagination_link>

            <.pagination_link class="pointer-events-none" disabled>
              <%= @page_number %>
            </.pagination_link>

            <.pagination_link 
              navigate={uri(@page_path, %{page: @total_pages})} 
              class={if @page_number == @total_pages, do: "pointer-events-none", else: ""}>
              &gt;&gt;
            </.pagination_link>

            <.pagination_link 
              navigate={uri(@page_path, %{page: @page_number + 1})} 
              class={if @page_number == @total_pages, do: "pointer-events-none", else: ""}>
              &gt;
            </.pagination_link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp fetch_tickets(socket) do
    page_params = %{
      page: socket.assigns.page || 1,
      page_size: socket.assigns.per_page
    }

    page = Ticket.get_user_tickets(
      socket.assigns.current_user.id,
      socket.assigns.status,
      page_params
    )

    assign(socket,
      tickets: page.entries,
      page_number: page.page_number,
      total_pages: page.total_pages,
      total_entries: page.total_entries
    )
  end

  defp uri(path, params) do
    uri = URI.parse(path)
    query = URI.encode_query(params)
    %{uri | query: query} |> URI.to_string()
  end
end
