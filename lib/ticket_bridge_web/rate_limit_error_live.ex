defmodule TicketBridgeWeb.RateLimitErrorLive do
  use TicketBridgeWeb, :live_view
  # Add the auth hooks that set current_user
  on_mount {TicketBridgeWeb.UserAuth, :mount_current_user}
  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center min-h-[400px]">
    <div class="max-w-md text-center px-4">
    <.header class="text-center">
    Too Many Attempts
    <:subtitle>
    <div class="mt-4">
      Please wait 5 minutes before trying again.
    </div>

    <div class="mt-6 mb-6 text-left mx-auto" style="display: inline-block; width: auto;">
      • If you are using a VPN, try to disable it.<br>
        • Abusing the system may get you permanently banned.
      </div>

      <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
        Return to login
      </.link>
      </:subtitle>
      </.header>
    </div>
    </div>
    """
  end
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
