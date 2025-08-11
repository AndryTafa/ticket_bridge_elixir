# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TicketBridge.Repo.insert!(%TicketBridge.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias TicketBridge.Repo
alias TicketBridge.Accounts
alias TicketBridge.Ticket

# Clear existing data
Repo.delete_all(Ticket)
Repo.delete_all("users_tokens")
Repo.delete_all("users")

# Create test user
{:ok, user} = Accounts.register_user(%{
  email: "test@example.com",
  password: "test"
})

# Create test tickets
[
  %{
    user_id: user.id,
    subject: "Cannot login to account",
    message: "I've been trying to login but keep getting errors",
    priority: "high",
    status: "open",
    category: "authentication",
    user_agent_details: %{browser: "Chrome", os: "Windows"}
  },
  %{
    user_id: user.id,
    subject: "Feature request: Dark mode",
    message: "Would love to see a dark mode option",
    priority: "low",
    status: "open",
    category: "feature_request",
    user_agent_details: %{browser: "Firefox", os: "MacOS"}
  }
]
|> Enum.each(fn ticket_data ->
  %Ticket{}
  |> Ticket.changeset(ticket_data)
  |> Repo.insert!()
end)

IO.puts "Seed data inserted successfully!"
IO.puts "\nTest User Credentials:"
IO.puts "Email: test@example.com"
IO.puts "Password: test"
