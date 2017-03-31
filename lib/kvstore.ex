defmodule KVstore do
  require Logger
  use Application
  use Supervisor

  def start(_type, _) do
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, KVstore.Router, [], port: get_port()),
      worker(KVstore.Cleaner, [])
    ]
    opts = [strategy: :one_for_one, name: KVstore.Supervisor]
    Logger.info "start http server on port #{get_port()}"
    KVstore.Storage.init()
    Supervisor.start_link(children, opts)
  end 

  defp get_port(), do: Application.get_env(:kvstore, :http_port)

end