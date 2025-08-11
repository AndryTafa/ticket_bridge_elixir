defmodule TicketBridgeWeb.Router do
  use TicketBridgeWeb, :router
  import TicketBridgeWeb.UserAuth
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TicketBridgeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :unauthenticated_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TicketBridgeWeb.Layouts, :unauthenticated_root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug TicketBridgeWeb.Plugs.ApiAuth
  end

  scope "/", TicketBridgeWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  scope "/api", TicketBridgeWeb do
    pipe_through :api

    post "/tickets", TicketController, :create
  end

  if Application.compile_env(:ticket_bridge, :dev_routes) do

    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router
    import Plug.BasicAuth
    scope "/dev" do
      pipe_through [:browser, :admin_auth]
      live_dashboard "/dashboard", metrics: TicketBridgeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end

    pipeline :admin_auth do
      plug :basic_auth, username: "get_from_env", password: "get_from_env"
    end
  end

  ## Authentication routes

  scope "/", TicketBridgeWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [
        {TicketBridgeWeb.UserAuth, :redirect_if_user_is_authenticated},
        {TicketBridgeWeb.InitAssigns, :init_ip}
      ],
      layout: {TicketBridgeWeb.Layouts, :unauthenticated_root} do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit

      live "/rate-limited", RateLimitErrorLive
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/app", TicketBridgeWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{TicketBridgeWeb.UserAuth, :ensure_authenticated}] do
      live "/dashboard", DashboardLive, :dashboard
      live "/tickets/closed", Tickets.Closed, :tickets_closed
      live "/tickets/pending", Tickets.Pending, :tickets_pending

      live "/tickets/:id", Tickets.Show, :tickets_show

      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", TicketBridgeWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{TicketBridgeWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
