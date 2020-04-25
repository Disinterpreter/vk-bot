defmodule Webserver.Commands.Tyan do
  require Logger
  def exec(data) do
    {:ok ,%{"message" => %{"peer_id" => peer_id} }} = data
    keyboard = %{
      "buttons" => [
        [
          %{
            "action" => %{
              "type" => "text",
              "label" => "тяночку",
              "payload" => ""
            },
            color: "negative"
          }
        ],
      ],
      "inline" => true
    }

    # Groups dataset
    groups = [
      -79458616,
      -132807795,
      -121581173,
      -54709527,
      -130914885,
      -111044288,
      -102853758,
      -134982584
    ]

    {:ok, wallurl} = Webserver.Vk.wallGet(groups)

    outputData = %{
      peer_id: peer_id,
      random_id: Enum.random(0..999999999),
      message: "Тян",
      attachment: wallurl,
      keyboard: Jason.encode!(keyboard)
    }
    case Webserver.Vk.invoke("g", "messages.send", outputData) do
      {:ok, body} -> {:ok, body}
      {:error, reason} -> {:error, reason}
    end
  end
end
