defmodule TicketBridgeWeb.InitAssigns do
  import Phoenix.Component
  import Phoenix.LiveView

  def on_mount(:init_ip, _params, _session, socket) do
    peer_data = get_connect_info(socket, :peer_data)
    
    ip = case peer_data do
      %{address: address} when not is_nil(address) ->
        address |> :inet.ntoa() |> to_string()
      _ ->
        # Fallback to x-real-ip or x-forwarded-for header if behind proxy
        headers = get_connect_info(socket, :x_headers) || []
        case Enum.find(headers, fn {header, _} -> header in ["x-real-ip", "x-forwarded-for"] end) do
          {_, value} -> value
          _ -> "0.0.0.0"  # fallback IP
        end
    end

    {:cont, assign(socket, :client_ip, ip)}
  end
end
