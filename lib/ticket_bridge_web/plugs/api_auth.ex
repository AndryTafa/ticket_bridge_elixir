defmodule TicketBridgeWeb.Plugs.ApiAuth do
  import Plug.Conn

  alias TicketBridge.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
      {:ok, user} <- Accounts.fetch_user_by_api_token(token) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> send_resp(:unauthorized, "Unauthorized")
        |> halt()
    end
  end
end
