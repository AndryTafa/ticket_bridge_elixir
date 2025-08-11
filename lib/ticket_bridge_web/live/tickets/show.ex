defmodule TicketBridgeWeb.Tickets.Show do
  use TicketBridgeWeb, :live_view
  import SaladUI.Select
  alias TicketBridgeWeb.Helpers.PathHelpers
  alias TicketBridge.Ticket
  import PathHelpers

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Ticket.get_ticket(id, socket.assigns.current_user.id) do
      nil ->
        {:ok,
          socket
          |> put_flash(:error, "Ticket not found")
          |> redirect(to: ~p"/app/dashboard")}
      ticket ->
        {:ok,
          socket
          |> assign(:ticket, ticket)
          |> assign(:ticket_status, ticket.status)
          |> assign(:ticket_priority, ticket.priority)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto">
      <div class="bg-white border rounded-lg overflow-hidden">
        <form id="ticket-form" phx-submit="update_ticket" >
          <div class="px-6 py-4 border-b border-gray-100">
            <div class="flex items-center justify-between space-x-4">
              <div class="flex items-center space-x-2">
                <h1 class="text-xl font-semibold text-gray-900">
                  Ticket #<%= @ticket.user_ticket_number %>
                </h1>
              </div>
              <div class="flex items-center space-x-4">
                <div class="flex flex-col">
                  <label for="ticket-priority-select" class="text-sm font-semibold text-gray-700 mb-1">
                    Priority
                  </label>
                  <.select
                    :let={select}
                    id="ticket-priority-select"
                    name="ticket_priority"
                    value={@ticket.priority}
                    placeholder="Select Priority"
                    >
                    <.select_trigger builder={select} class="w-[180px]" />
                    <.select_content builder={select} class="w-full">
                      <.select_group>
                        <.select_label>Priority</.select_label>
                        <.select_item builder={select} value="low" label="Low"></.select_item>
                        <.select_item builder={select} value="medium" label="Medium"></.select_item>
                        <.select_item builder={select} value="high" label="High"></.select_item>
                      </.select_group>
                    </.select_content>
                  </.select>
                </div>
                <div class="flex flex-col">
                  <label for="ticket-status-select" class="text-sm text-gray-700 mb-1 font-semibold">
                    Status
                  </label>
                  <.select
                    :let={select}
                    id="ticket-status-select"
                    name="ticket_status"
                    value={@ticket.status}
                    placeholder="Select Status"
                    >
                    <.select_trigger builder={select} class="w-[180px]" />
                    <.select_content builder={select} class="w-full">
                      <.select_group>
                        <.select_label>Status</.select_label>
                        <.select_item builder={select} value="open" label="Open"></.select_item>
                        <.select_item builder={select} value="pending" label="Pending"></.select_item>
                        <.select_item builder={select} value="closed" label="Closed"></.select_item>
                      </.select_group>
                    </.select_content>
                  </.select>
                </div>
              </div>
            </div>
          </div>
          <div class="px-6 py-4 space-y-4">
            <div>
              <h2 class="text-sm font-medium text-gray-500 mb-1">Subject</h2>
              <p class="text-gray-900"><%= @ticket.subject %></p>
            </div>
            <div>
              <h2 class="text-sm font-medium text-gray-500 mb-1">Message</h2>
              <div class="mt-1 p-4 bg-gray-50 rounded-lg border border-gray-100">
                <pre class="whitespace-pre-wrap text-gray-700 text-sm"><%= @ticket.message %></pre>
              </div>
            </div>
          </div>
          <div class="px-6 py-4 border-t border-gray-100 flex items-center justify-between">
            <.link patch={dashboard_path()} class="inline-flex items-center text-sm text-gray-900 hover:text-black">
              <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M10 19l-7-7m0 0l7-7m-7 7h18" />
              </svg>
              Back to Dashboard
            </.link>
            <SaladUI.Button.button type="submit" variant="default" class="text-sm" size="sm" phx-disable-with="Saving...">
              Save
            </SaladUI.Button.button>
          </div>
        </form>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("update_ticket", params, socket) do
    changes = %{}
      |> maybe_add_change(params, "ticket_status", :status, socket.assigns.ticket.status)
      |> maybe_add_change(params, "ticket_priority", :priority, socket.assigns.ticket.priority)

    if changes != %{} do
      case Ticket.update_ticket(socket.assigns.ticket, changes) do
        {:ok, updated_ticket} ->
          {:noreply,
            socket
            |> assign(:ticket, updated_ticket)
            |> push_navigate(to: dashboard_path())
            |> put_flash(:info, "Ticket updated successfully")}
        {:error, _changeset} ->
          {:noreply,
            socket
            |> put_flash(:error, "Could not update ticket")}
      end
    else
      {:noreply,
        socket 
        |> push_navigate(to: dashboard_path())
        |> put_flash(:info, "Ticket updated successfully")}
    end
  end

  defp maybe_add_change(changes, params, param_key, field_key, current_value) do
    case Map.get(params, param_key) do
      nil -> changes
      new_value when new_value != current_value ->
        Map.put(changes, field_key, new_value)
      _ -> changes
    end
  end

  defp priority_color("high"), do: "#ef4444"
  defp priority_color("medium"), do: "#eab308"
  defp priority_color("low"), do: "#22c55e"
  defp priority_color(_), do: "#6b7280"

  defp status_color("open"), do: "#ef4444"
  defp status_color("pending"), do: "#f97316"
  defp status_color("closed"), do: "#22c55e"
  defp status_color(_), do: "#ffffff"
end
