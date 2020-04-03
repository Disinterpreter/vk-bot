defmodule Webserver.Commands.Advice do
  require Logger
  require HTTPoison
  require Jason

  def exec(data) do
    {:ok ,%{"peer_id" => peer_id}} = data

    case HTTPoison.get("http://fucking-great-advice.ru/api/random") do
        {:error, reason} ->
          Webserver.Vk.messageSend(peer_id, "Проверь команду", "")
          {:error, reason}
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          %{"id" => id,"text" => text} = Jason.decode!(body)
          Webserver.Vk.messageSend(peer_id, "Совет №#{id}: #{text}", "")
          {:ok, body}
      end
  end
end
