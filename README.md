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

## REST API

### localhost:8020/crud/create

Сохраняет значение по новому ключу на **ttl** секунд

POST запрос. Обязательные параметры - key, value, ttl

### localhost:8020/crud/get/{key}

Извлекает их хранилища значение по ключу **key**. В случае отсутсвия такого ключа возвращет ошибку

GET запрос

### localhost:8020/crud/update/{key}

Заменят значение ключа **key** на новое значение **value**. В случае отсуствия такого ключа возвращает ошибку

POST запрос. Обязательные параметры - value

### localhost:8020/crud/delete/{key}

Удаляет ключ **key** из хранилища. В случае отсуствия такого ключа возвращает ошибку. Длительность хранения ключа при этом не меняется

POST запрос.


## Elixir API

**module KVstore.Storage**

### create(key :: term, value :: term, ttl :: integer) :: :ok | {:error, {code, message}} 

Сохраняет значение **value** для дальнейшего доступа по ключу **key**
Пара ключ - значение хранится в течении **ttl** секунд
В случае, если такой ключ уже есть в хранилище возвращает ошибку

### get(key :: term) :: {:ok, value} | {:error, {code, message}}

Извлекает их хранилища значение по ключу **key**. В случае отсутсвия такого ключа возвращет ошибку

### update(key :: term, value :: term) :: :ok | {:error, {code, message}} 

Заменят значение ключа **key** на новое значение **value**. В случае отсуствия такого ключа возвращает ошибку. Длительность хранения ключа при этом не меняется

### delete(key :: term) :: {:ok, value} | {:error, {code, message}}

Удаляет ключ **key** из хранилища. В случае отсуствия такого ключа возвращает ошибку


License
-------

This project is under the **MIT** License. See the [LICENSE](LICENSE) file for the full license text.

