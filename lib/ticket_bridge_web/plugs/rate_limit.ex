defmodule TicketBridgeWeb.Plugs.RateLimit do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts) do
    Enum.into(opts, %{
      key_prefix: "rate_limit",
      scale: :timer.minutes(5),
      limit: 7,
      on_deny: &default_on_deny/2,
      json_response: false
    })
  end

  def call(conn, opts) do
    ip = conn.remote_ip |> :inet.ntoa() |> to_string()
    key = "#{opts.key_prefix}:#{ip}"
    case TicketBridge.RateLimit.hit(key, opts.scale, opts.limit) do
      {:allow, _count} ->
        conn
      {:deny, retry_after} ->
        conn
        |> put_resp_header("retry-after", Integer.to_string(div(retry_after, 1000)))
        |> opts.on_deny.(retry_after)
        |> halt()
    end
  end

  defp default_on_deny(conn, retry_after) do
    if conn.private[:json_response] || Map.get(conn.private, :rate_limit_json_response, false) do
      conn
      |> put_status(:too_many_requests)
      |> json(%{error: "Rate limit exceeded, try again in a few minutes."})
    else
      conn
      |> redirect(to: "/rate-limited")
    end
  end
end
