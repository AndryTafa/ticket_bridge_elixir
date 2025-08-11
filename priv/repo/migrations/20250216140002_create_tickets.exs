defmodule TicketBridge.Repo.Migrations.CreateTickets do
  use Ecto.Migration
  def change do
    create table(:tickets, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users), null: false
      add :user_ticket_number, :integer
      add :priority, :string
      add :is_read, :boolean, default: false
      add :subject, :string
      add :message, :text
      add :user_agent_details, :map
      add :status, :string, default: "open"
      add :category, :string
      timestamps(type: :utc_datetime)
    end

    create index(:tickets, [:user_id])
    create index(:tickets, [:user_id, :is_read])
    create unique_index(:tickets, [:user_id, :user_ticket_number])
  end
end
