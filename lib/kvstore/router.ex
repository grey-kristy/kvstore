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


  defp create(%{"key" => key, "value" => value, "ttl" => ttl}), do: create(key, value, ttl)
  defp create(_), do: {:error, {:no_field, "required field is absent"}}

  defp create(key, value, ttl) do
    case Integer.parse(ttl) do
      {ttl, ""} when ttl <= 0 -> {:error, {:wrong_ttl, "ttl is not positive"}}
      {ttl, ""} -> KV.create(key, value, ttl)
      {_, _}    -> {:error, {:wrong_ttl, "ttl is not integer"}}
      :error    -> {:error, {:wrong_ttl, "ttl is not integer"}}
    end
  end

  defp update(key, %{"value" => value}), do: KV.update(key, value)
  defp update(_,_), do: {:error, "required field is absent"}

  defp get_params(conn) do
    {:ok, body, conn} = read_body(conn, [])
    params = Plug.Conn.Query.decode(body)
    Logger.debug "params: #{inspect params}"
    {conn, params}
  end

  defp out(conn, :ok), do: send_resp(conn, 200, "done")
  defp out(conn, {:ok, result}), do: send_resp(conn, 200, result)
  defp out(conn, {:error, {code, message}}), do: send_resp(conn, http_error_code(code), message)

  defp http_error_code(:no_key), do: 404
  defp http_error_code(:key_exist), do: 417
  defp http_error_code(_), do: 400


end
