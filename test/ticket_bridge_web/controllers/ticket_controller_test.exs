defmodule TicketBridgeWeb.TicketControllerTest do
  use TicketBridgeWeb.ConnCase

  @valid_attrs %{
    user_id: 1,  # You'll need to create a user first in your test setup
    subject: "Test Ticket",
    message: "This is a test ticket",
    priority: "high",
    category: "support"
  }

  describe "create ticket" do
    test "creates and renders ticket when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/tickets", @valid_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]
      
      assert json_response(conn, 201)["data"] == %{
        "id" => id,
        "user_id" => @valid_attrs.user_id,
        "subject" => @valid_attrs.subject,
        "message" => @valid_attrs.message,
        "priority" => @valid_attrs.priority,
        "category" => @valid_attrs.category,
        "is_read" => false,
        "status" => nil,
        "inserted_at" => DateTime.to_iso8601(DateTime.utc_now())
      }
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/tickets", %{})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
