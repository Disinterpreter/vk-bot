defmodule Webserver.Parser do
  require Logger
  require Jason
  require Webserver.Pgdb

  def parse(body) do
    json =Jason.decode!(body)

    # IO.inspect(json)
    {:ok, type} = Map.fetch(json, "type")
    if type == "message_new" do
      obj = Map.fetch(json, "object")
      {:ok, %{"message" => %{ "peer_id" => peer_id, "from_id" => from_id, "text" => text } } } = obj


      botst = Application.get_env(:webserver, Botsettings)
      btype = String.match?(text, ~r/^#{botst[:determinator]}|^\[club#{botst[:clubid]}\|/iu)

      if (btype) do
        case String.split(text, " ") do
          [_determinant, cmd | _args] ->
            {:ok, call_cmd} = Webserver.Pgdb.checkCommand(from_id, peer_id, cmd)

             if (call_cmd != "NULL") do
              apply(String.to_atom("Elixir.Webserver.Commands."<> call_cmd), String.to_atom("exec"), [Map.fetch(json, "object")])
              {:ok}
             else
              {:ok}
             end

            _ -> {:ok}
        end
      end

      {:ok}
    else
      {:ok}
    end
    {:ok}
  end
end
