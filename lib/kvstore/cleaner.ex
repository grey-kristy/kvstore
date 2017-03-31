defmodule KVstore.Cleaner do
  require Logger
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init(_) do
    send __MODULE__, {:init}
    {:ok, {}}
  end

  def schedule_cleanup(key, ttl) do
    Process.send_after(__MODULE__, {:add, key}, 1000*ttl)
    :ok
  end

  def handle_info({init}, state) do
    KVstore.Storage.refresh_ttl()
    {:noreply, state}
  end

  def handle_info({:add, key}, state) do
    KVstore.Storage.delete(key)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.info "#{__MODULE__} unexpected messsage: #{inspect msg}"
    {:noreply, state}
  end

end
