defmodule TicketBridge.Repo do
  use Ecto.Repo, otp_app: :ticket_bridge, adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 5
end
