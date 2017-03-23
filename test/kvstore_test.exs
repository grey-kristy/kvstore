defmodule KVstoreTest do
  use ExUnit.Case
  use Plug.Test

  @opts KVstore.Router.init([])

  setup_all do
    KVstore.Storage.clear()
    :ok
  end

  test "create" do
    key = 'qwe001'
    value = "42"
    check_get("/crud/get/#{key}", 404, "no such key")
    check_post("/crud/create", "key=#{key}&value=#{value}&ttl=1000", 200, "created")
    check_get("/crud/get/#{key}", 200, value)
    check_post("/crud/create", "key=#{key}&value=#{value}&ttl=1000", 417, "key already exist")
  end

  test "delete" do
    key = 'qwe002'
    value = "44"
    check_post("/crud/create", "key=#{key}&value=#{value}&ttl=1000", 200, "created")
    check_get("/crud/get/#{key}", 200, value)
    check_post("/crud/delete/#{key}", "", 200, "deleted")
    check_get("/crud/get/#{key}", 404, "no such key")
  end

  test "update" do
    key = 'qwe003'
    value = "46"
    value2 = "48"
    check_post("/crud/create", "key=#{key}&value=#{value}&ttl=1000", 200, "created")
    check_get("/crud/get/#{key}", 200, value)
    check_post("/crud/update/#{key}", "value=#{value2}", 200, "updated")
    check_get("/crud/get/#{key}", 200, value2)
    check_post("/crud/update/no_key", "value=#{value2}", 404, "no such key")
  end

  test "ttl" do
    key = 'qwe004'
    value = "50"
    ttl = 1
    check_post("/crud/create", "key=#{key}&value=#{value}&ttl=#{ttl}", 200, "created")
    check_get("/crud/get/#{key}", 200, value)
    Process.sleep(1000*ttl + 100)
    check_get("/crud/get/#{key}", 404, "no such key")
  end

  test "wrong_ttl" do
    key = "qwe005"
    value = "52"
    check_post("/crud/create", "key=#{key}&value=#{value}&ttl=abcd", 400, "ttl is not integer")
    check_post("/crud/create", "key=#{key}&value=#{value}&ttl=45.4", 400, "ttl is not integer")
    check_post("/crud/create", "key=#{key}&value=#{value}&ttl=-250", 400, "ttl is not positive")
    check_post("/crud/create", "key=#{key}&value=#{value}&ttl=0",    400, "ttl is not positive")
    check_post("/crud/create", "key=#{key}&value=#{value}&ttl=2000", 200, "created")
    check_get("/crud/get/#{key}", 200, value)
  end

  test "get_no_key", do: check_get("/crud/get/no_key", 404, "no such key")

  test "wrong_path", do: check_get("/", 406, "unknown action")

  defp check_post(path, request, status, body) do
    conn = conn(:post, path, request)
      |> put_req_header("content-type", "application/x-www-form-urlencoded")
      |> KVstore.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == status
    assert conn.resp_body == body
  end

  defp check_get(path, status, body) do
    conn = conn(:get, path, "")
           |> KVstore.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == status
    assert conn.resp_body == body
  end

end
