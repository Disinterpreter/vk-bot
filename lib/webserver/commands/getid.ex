defmodule Webserver.Commands.Getid do
  require Logger

  def exec(data) do
      # {:ok, body} = Webserver.Vk.messageSend(36556227, "Hai", "")
      {:ok ,%{"from_id" => from_id, "peer_id" => peer_id}} = data

      message = "Ваш айди: #{from_id}\n Айди конференции: #{peer_id}.\n"
      Webserver.Vk.messageSend(peer_id, message, "")

      {:ok}
  end
end
