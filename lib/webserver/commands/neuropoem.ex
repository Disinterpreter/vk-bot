defmodule Webserver.Commands.Neuropoem do
  require Logger
  require HTTPoison
  require Jason
  def exec(data) do
    name = Application.get_env(:webserver, Botsettings)

      {:ok ,%{"message" => %{"peer_id" => peer_id, "id" => msgid, "text" => msgtext} }} = data


      ### CUTTER
      msgarray = Enum.reverse( String.split(msgtext, " ") )
      msgarray = msgarray -- ["продолжи", name[:determinator], name[:mention]]
      argstring = Enum.join(Enum.reverse(msgarray), " ")
      #####

      prepjson = %{
        "prompt" => argstring,
        "length" => 30,
        "num_samples" => 1
      }
      case HTTPoison.post("https://models.dobro.ai/gpt2/medium/", Jason.encode!(prepjson)) do
        {:error, reason} ->
          Webserver.Vk.messageSend(peer_id, "Проверь команду", "")
          {:error, reason}
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          %{"replies" => [monolog]} = Jason.decode!(body)
          outputData = %{
            peer_id: peer_id,
            random_id: Enum.random(0..999999999),
            message: "Бот не несет отвественности за созданный текст <br><br><br> #{argstring} #{monolog}",
            reply_to: msgid

          }
          case Webserver.Vk.invoke("g", "messages.send", outputData) do
            {:ok, body} -> {:ok, body}
            {:error, reason} -> {:error, reason}
          end
          {:ok, body}
      end

      {:ok}
  end
end
