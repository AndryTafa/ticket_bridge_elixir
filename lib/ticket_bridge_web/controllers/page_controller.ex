defmodule TicketBridgeWeb.PageController do
  use TicketBridgeWeb, :controller

  def home(conn, _params) do
    if conn.assigns.current_user do
      redirect(conn, to: ~p"/app/dashboard")
    else
      render(conn, :home, layout: false)
    end
  end
end
