# KVstore

Simpe Key-Value Storage (Elixir test)

## Test

```
mix deps.get
mix test
```

## Run

To run and play:

iex -S mix

```
curl -d 'key=qwe&value=123&ttl=1000' localhost:8020/crud/create
curl localhost:8020/crud/get/qwe
curl -d 'value=456' localhost:8020/crud/update/qwe
curl -d '' localhost:8020/crud/delete/qwe
```

License
-------

This project is under the **MIT** License. See the [LICENSE](LICENSE) file for the full license text.

