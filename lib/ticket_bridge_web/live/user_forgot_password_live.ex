defmodule TicketBridgeWeb.UserForgotPasswordLive do
  use TicketBridgeWeb, :live_view
  alias TicketBridge.Accounts
  alias TicketBridge.RateLimit

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Forgot your password?
        <:subtitle>We'll send a password reset link to your inbox</:subtitle>
      </.header>

      <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full">
            Send password reset instructions
          </.button>
        </:actions>
      </.simple_form>

      <p class="text-center text-sm mt-4">
        <.link href={~p"/users/register"}>Register</.link>
        | <.link href={~p"/users/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    ip = case get_connect_info(socket, :peer_data) do
      %{address: {127, 0, 0, 1}} -> "127.0.0.1"
      %{address: {a, b, c, d}} -> "#{a}.#{b}.#{c}.#{d}"
      _ -> "0.0.0.0"
    end

    {:ok, 
      socket
      |> assign(:form, to_form(%{}, as: "user"))
      |> assign(:client_ip, ip)}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    key = "rate_limit:#{socket.assigns.client_ip}"

    case RateLimit.hit(key, :timer.minutes(5), 3) do
      {:allow, _count} ->
        if user = Accounts.get_user_by_email(email) do
          Accounts.deliver_user_reset_password_instructions(
            user,
            &url(~p"/users/reset_password/#{&1}")
          )
        end

        info =
          "If your email is in our system, you will receive instructions to reset your password shortly."

        {:noreply,
          socket
          |> put_flash(:info, info)
          |> redirect(to: ~p"/")}

      {:deny, retry_after} ->
        {:noreply,
          socket
          |> put_flash(:error, "Too many password reset attempts. Please try again in #{div(retry_after, 1000)} seconds.")
          |> redirect(to: ~p"/rate-limited")}
    end
  end
end
