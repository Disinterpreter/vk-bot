defmodule Webserver.Vk do
  require Logger
  require HTTPoison
  require Jason

  defp request(config, token, args, vkurl) do
    args = Map.put(args, :v, config[:v])
    args = Map.put(args, :access_token, token)
    req_body = URI.encode_query(args)

    case HTTPoison.post(vkurl,req_body, %{"Content-Type" => "application/x-www-form-urlencoded"}) do
      {:error, reason} -> {:error, reason}
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body}
    end
  end

  def invoke(btoken, method, args) do
    vkurl = "https://api.vk.com/method/" <> method

    vkconf = Application.get_env(:webserver, Vk)
    if btoken == "g" do
      token = vkconf[:grouptoken]
      case request(vkconf, token, args, vkurl) do
        {:ok, body} -> {:ok, body}
        {:error, reason} -> {:error, reason}
      end
    else
      token = vkconf[:usertoken]
      case request(vkconf, token, args, vkurl) do
        {:ok, body} -> {:ok, body}
        {:error, reason} -> {:error, reason}
      end
    end
  end

  def messageSend(peer, message, attach) do

    outputData = %{
      peer_id: peer,
      random_id: Enum.random(0..999999999),
      message: message,
      attachment: attach
    }
    case invoke("g", "messages.send", outputData) do
      {:ok, body} -> {:ok, body}
      {:error, reason} -> {:error, reason}
    end
  end

  def wallGet (grouplist) do
    group = Enum.random(grouplist)
    prepareData = %{
      count: 1,
      offset: Enum.random(0..200000),
      owner_id: group
    }
    case invoke("u", "wall.get", prepareData) do
      {:ok, body} ->
        %{"response" => %{"count" => lastid, "items" => items}} = Jason.decode!(body)
        if( length(items) == 0) do
          case invoke("u", "wall.get", %{
            count: 1,
            offset: Enum.random(0..lastid),
            owner_id: group
          }) do
            {:ok, body} ->
              %{"response" => %{"items" => items}} = Jason.decode!(body)
              [head | _tail] = items
              %{"from_id" => from_id, "id"=> id} = head

              {:ok, "wall#{from_id}_#{id}"}
            {:error, reason} ->{:error, reason}
          end
        else
          %{"response" => %{"items" => items}} = Jason.decode!(body)
          [head | _tail] = items
          %{"from_id" => from_id, "id"=> id} = head

          {:ok, "wall#{from_id}_#{id}"}
        end
      {:error, reason} ->{:error, reason}
    end
  end
end
