defmodule Sqlite3Fun.Repo do
  use Ecto.Repo,
    otp_app: :sqlite3_fun,
    adapter: Ecto.Adapters.SQLite3
end
