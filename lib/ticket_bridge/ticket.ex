defmodule TicketBridge.Ticket do
  alias TicketBridgeWeb.Tickets
  alias TicketBridge.Ticket
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias TicketBridge.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @priority_weights %{
    "high" => 3,
    "medium" => 2,
    "low" => 1
  }

  schema "tickets" do
    belongs_to :user, TicketBridge.Accounts.User
    field :user_ticket_number, :integer
    field :priority, :string
    field :is_read, :boolean, default: false
    field :subject, :string
    field :message, :string
    field :user_agent_details, :map
    field :status, :string
    field :category, :string
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [:user_id, :priority, :is_read, :subject, :message, :user_agent_details, :status, :category])
    |> validate_required([:user_id, :subject, :message])
    |> normalize_priority()
    |> validate_inclusion(:priority, Map.keys(@priority_weights))
    |> unique_constraint([:user_id, :user_ticket_number])
  end

  defp normalize_priority(changeset) do
    case get_change(changeset, :priority) do
      nil -> changeset
      priority when is_binary(priority) ->
        put_change(changeset, :priority, String.downcase(priority))
      _ -> changeset
    end
  end

  def create_ticket(attrs) do
    user_id = attrs["user_id"]
    next_number = get_next_ticket_number(user_id)

    %Ticket{}
    |> changeset(attrs)
    |> Ecto.Changeset.put_change(:user_ticket_number, next_number)
    |> Repo.insert()
  end

  defp get_next_ticket_number(user_id) do
    query = from t in Ticket,
      where: t.user_id == ^user_id,
      select: max(t.user_ticket_number)

    case Repo.one(query) do
      nil -> 1
      max_number -> max_number + 1
    end
  end

  def update_ticket(%Ticket{} = ticket, attrs) do
    ticket
    |> Ticket.changeset(attrs)
    |> Repo.update()
  end

  def get_ticket(id, user_id) do
    Ticket
    |> where(id: ^id)
    |> where(user_id: ^user_id)
    |> Repo.one()
  end

  defp base_query(user_id, status) do
    Ticket
    |> where(user_id: ^user_id)
    |> maybe_add_status(status)
    |> order_by([t], [
      asc: fragment("CASE WHEN LOWER(priority) = 'high' THEN 1 WHEN LOWER(priority) = 'medium' THEN 2 WHEN LOWER(priority) = 'low' THEN 3 ELSE 4 END"),
      desc: t.user_ticket_number
    ])
  end

  defp maybe_add_status(query, status) when status in [:open, :closed, :pending] do
    where(query, [t], t.status == ^Atom.to_string(status))
  end
  defp maybe_add_status(query, _), do: query

  def get_user_tickets(user_id, status, params \\ %{}) do
    user_id
    |> base_query(status)
    |> Repo.paginate(params)
  end
end
