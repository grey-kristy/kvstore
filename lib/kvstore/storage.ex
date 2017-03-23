defmodule KVstore.Storage do
  require Logger

  defp table_name(), do: Application.get_env(:kvstore, :dets_table_name)

  def init() do
    {:ok, _table} = :dets.open_file(table_name(), [type: :set, auto_save: 10000])
    refresh_ttl()
  end

  def clear() do
    :ok = :dets.delete_all_objects(table_name())
  end

  def refresh_ttl() do
    now = now()
    :dets.traverse(table_name(), fn(item) -> process_ttl(now, item) end)
  end

  defp process_ttl(now, {key, _value, ttl}) do
    case ttl do
      ttl when ttl < now ->
        delete(key)
      ttl ->
        spawn(fn ->
          Process.sleep(1000*(ttl-now))
          delete(key)
        end)        
    end
    :continue
  end

  defp now(), do: DateTime.to_unix( DateTime.utc_now() )

  def get(key) do
    Logger.debug "trying to get key #{key}"
    case :dets.lookup(table_name(), key) do
      [{_key, value, _ttl}] -> {200, value}
      []                    -> {404, "no such key"}
    end
  end

  def create(key, value, ttl) when is_integer(ttl) do
    Logger.debug "trying to create key #{key}, value #{value}"
    case :dets.insert_new(table_name(), {key, value, now()+ttl}) do
      true  ->
        spawn(fn ->
          Process.sleep(1000*ttl)
          delete(key)
        end)
        {200, "created"}
      false ->
        {417, "key already exist"}
    end
  end

  def create(key, value, ttl) do
    case Integer.parse(ttl) do
      {ttl, ""} when ttl <= 0 -> {400, "ttl is not positive"}
      {ttl, ""} -> create(key, value, ttl)
      {_, _}    -> {400, "ttl is not integer"}
      :error    -> {400, "ttl is not integer"}
    end
  end

  def delete(key) do
    Logger.debug "trying to delete key #{key}"
    :ok = :dets.delete(table_name(), key)
    {200, "deleted"}
  end

  def update(key, value) do
    Logger.debug "trying to update key #{key} to #{value}"
    case :dets.lookup(table_name(), key) do
      [{_key, _value, ttl}] ->
        :ok = :dets.insert(table_name(), {key, value, ttl})
        {200, "updated"}
      []  ->
        {404, "no such key"}
      end
  end

end
