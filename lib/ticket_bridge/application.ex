defmodule TicketBridge.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TicketBridgeWeb.Telemetry,
      TicketBridge.Repo,
      {DNSCluster, query: Application.get_env(:ticket_bridge, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TicketBridge.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: TicketBridge.Finch},
      # Start to serve requests, typically the last entry
      TicketBridgeWeb.Endpoint,
      TwMerge.Cache,
      {TicketBridge.RateLimit, [clean_period: :timer.minutes(1)]}
    ]

    opts = [strategy: :one_for_one, name: TicketBridge.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    TicketBridgeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
