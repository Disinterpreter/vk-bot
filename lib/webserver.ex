defmodule Webserver do
  import Plug.Conn
  require Logger
  require Webserver.Confirmation
  require Webserver.Parser
  def init(options), do: options

  def call(conn, opts) do
    {:ok, state, sbody} = Webserver.Confirmation.confProceed(conn, opts)
    vkconf = Application.get_env(:webserver, Vk)
    if state == 1 do
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, vkconf[:cbtoken])
    else
      Webserver.Parser.parse(sbody)
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, "ok\n")
    end
  end
end
