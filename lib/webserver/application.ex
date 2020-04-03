defmodule Webserver.Application do

  require Logger
  def start(_type, _args) do
    httpconf = Application.get_env(:webserver, Http)

    children = [
      {Plug.Cowboy, scheme: :http, plug: Webserver, options: [port: httpconf[:port]]}
    ]
    opts = [strategy: :one_for_one, name: Webserver.Supervisor]

    Logger.info("Starting application...")
    Supervisor.start_link(children, opts)
  end
end
