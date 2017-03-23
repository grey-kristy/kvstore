defmodule KVstore.Router do
  require Logger
  use Plug.Router
  alias KVstore.Storage, as: KV

  plug :match
  plug :dispatch

  get  "/crud/get/:key",    do: out(conn, KV.get(key))
  post "/crud/delete/:key", do: out(conn, KV.delete(key))

  post "/crud/create" do
    {conn, params} = get_params(conn)
    out(conn, create(params))
  end

  post "/crud/update/:key" do
    {conn, params} = get_params(conn)
    out(conn, update(key, params))
  end

  match _, do: send_resp(conn, 406, "unknown action")


  defp create(%{"key" => key, "value" => value, "ttl" => ttl}), do: KV.create(key, value, ttl)
  defp create(_), do: {400, "required field is absent"}

  defp update(key, %{"value" => value}), do: KV.update(key, value)
  defp update(_,_), do: {400, "required field is absent"}

  defp get_params(conn) do
    {:ok, body, conn} = read_body(conn, [])
    params = Plug.Conn.Query.decode(body)
    Logger.debug "params: #{inspect params}"
    {conn, params}
  end

  defp out(conn, {status, body}) do
    send_resp(conn, status, body)
  end

end
