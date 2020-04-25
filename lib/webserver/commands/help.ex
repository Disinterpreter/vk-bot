defmodule Webserver.Commands.Help do
  require Logger

  def exec(data) do
      IO.inspect(data)
      {:ok}
  end
end
