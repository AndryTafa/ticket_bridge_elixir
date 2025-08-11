defmodule TicketBridge.RateLimit do
  use Hammer, backend: :ets
end
