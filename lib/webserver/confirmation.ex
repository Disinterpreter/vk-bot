
defmodule Webserver.Confirmation do
  require Logger
  require Jason
  defp read_body(conn, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
    conn = update_in(conn.assigns[:raw_body], &[body | (&1 || [])])
    {:ok, body, conn}
  end

  def confProceed(conn, opts) do
    {:ok, b, _c} = read_body(conn,opts)
    json =Jason.decode!(b)

    {:ok, answ} = Map.fetch(json, "type")
    if answ == "confirmation" do
      {:ok, 1, 0}
    else
      {:ok, 0, b}
    end
  end
end
