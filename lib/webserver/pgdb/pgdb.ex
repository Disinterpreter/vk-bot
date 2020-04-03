defmodule Webserver.Pgdb do
  require Logger
  require Postgrex

  defp connect() do
    dbconf = Application.get_env(:webserver, Db)
    {:ok, pid} = Postgrex.start_link(hostname: dbconf[:ip], username: dbconf[:user], password: dbconf[:password], database: dbconf[:dbname])
    {:ok, pid}
  end

  def checkCommand(id, chatid, cmd) do
      {:ok, pid}= connect()

      %Postgrex.Result{rows: [[call_cmd]]} = Postgrex.query!(pid, "SELECT call_cmd FROM call_cmd($1,$2,$3)", [id, chatid, cmd])

      {:ok, call_cmd}
  end
end
