defmodule Webserver.Pgdb do
  require Logger
  require Postgrex

  defp connect() do
    dbconf = Application.get_env(:webserver, Db)
    case Postgrex.start_link(hostname: dbconf[:ip], username: dbconf[:user], password: dbconf[:password], database: dbconf[:dbname]) do
      {:ok, pid} -> {:ok, pid}
      _ -> Process.sleep(1000); connect()
    end
  end

  def checkCommand(id, chatid, cmd) do
      {:ok, pid}= connect()

      %Postgrex.Result{rows: [[call_cmd]]} = Postgrex.query!(pid, "SELECT call_cmd FROM call_cmd($1,$2,$3)", [id, chatid, cmd])

      {:ok, call_cmd}
  end

  def getRoles(id) do
    {:ok, pid}= connect()

    %Postgrex.Result{rows: roles} = Postgrex.query!(pid, "SELECT f1 as id, f2 as name FROM get_roles($1)", [id])

    {:ok, roles}
  end
end
