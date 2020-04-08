defmodule Webserver.Commands.Joke do
  require Logger

  def exec(data) do
      groups = [
        -40232010,
        -92876084,
        -150550417,
        -73598440,
        -155464693,
        -148583957,
        -93082454,
        -164517505
      ]
      {:ok, wallurl} = Webserver.Vk.wallGet(groups)
      {:ok ,%{"message" => %{"peer_id" => peer_id} }} = data
      Webserver.Vk.messageSend(peer_id, "Вот", wallurl)
      {:ok}
  end
end
