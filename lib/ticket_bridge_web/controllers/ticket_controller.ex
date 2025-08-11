defmodule TicketBridgeWeb.TicketController do
  use TicketBridgeWeb, :controller
  alias TicketBridge.Ticket

  plug(:set_json_response when action in [:create])
  plug(TicketBridgeWeb.Plugs.RateLimit, [
    key_prefix: "rate_limit_api",
    scale: :timer.minutes(5),
    limit: 30 # can probably play around with this but i think 30 tickets per 5 minutes is good for most startups
  ] when action in [:create])

  def set_json_response(conn, _opts) do
    conn |> put_private(:rate_limit_json_response, true)
  end

  def create(conn, params) do
    user = conn.assigns[:current_user]

    # Ensure the ticket is associated with the authenticated user
    ticket_params = Map.merge(params, %{"user_id" => user.id})

    case Ticket.create_ticket(ticket_params) do
      {:ok, ticket} -> 
        conn
        |> put_status(:created)
        |> json(%{
          data: %{
            id: ticket.id,
            user_id: ticket.user_id,
            priority: ticket.priority,
            subject: ticket.subject,
            message: ticket.message,
            status: ticket.status,
            category: ticket.category,
            is_read: ticket.is_read,
            inserted_at: ticket.inserted_at
          }
        })

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
        })
    end
  end
  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
