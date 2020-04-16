defmodule Webserver.Commands.Roles do
  require Logger

  def exec(data) do
    {:ok ,%{"message" => %{"peer_id" => peer_id, "from_id" => from_id} }} = data

    {:ok, roles} = Webserver.Pgdb.getRoles(from_id)

    message =  "Твои текущие роли:<br>"<> Enum.join(roles, "<br>")
    Webserver.Vk.messageSend(peer_id,message, "")
    {:ok}
  end
end
