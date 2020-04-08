defmodule Webserver.Commands.Advice do
  require Logger
  require HTTPoison
  require Jason

  def exec(data) do
    {:ok ,%{"message" => %{"peer_id" => peer_id} }} = data
    keyboard = %{
      "buttons" => [
        [
          %{
            "action" => %{
              "type" => "text",
              "label" => "совет",
              "payload" => ""
            },
            color: "negative"
          }
        ],
      ],
      "inline" => true
    }

    case HTTPoison.get("http://fucking-great-advice.ru/api/random") do
        {:error, reason} ->
          Webserver.Vk.messageSend(peer_id, "Проверь команду", "")
          {:error, reason}
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          %{"id" => id,"text" => text} = Jason.decode!(body)
          # Webserver.Vk.messageSend(peer_id, "Совет №#{id}: #{text}", "")
          outputData = %{
            peer_id: peer_id,
            random_id: Enum.random(0..999999999),
            message: "Совет №#{id}: #{text}",
            keyboard: Jason.encode!(keyboard)
          }
          case Webserver.Vk.invoke("g", "messages.send", outputData) do
            {:ok, body} -> {:ok, body}
            {:error, reason} -> {:error, reason}
          end
          {:ok, body}
      end
  end
end
