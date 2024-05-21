defmodule Sqlite3Fun.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Sqlite3FunWeb.Telemetry,
      Sqlite3Fun.Repo,
      {Ecto.Migrator,
        repos: Application.fetch_env!(:sqlite3_fun, :ecto_repos),
        skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:sqlite3_fun, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Sqlite3Fun.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Sqlite3Fun.Finch},
      # Start a worker by calling: Sqlite3Fun.Worker.start_link(arg)
      # {Sqlite3Fun.Worker, arg},
      # Start to serve requests, typically the last entry
      Sqlite3FunWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sqlite3Fun.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Sqlite3FunWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
