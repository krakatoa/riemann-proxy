defmodule RiemannProxy.Endpoint do
  require Record
  Record.defrecord :endpoint, [:idx, :host, port: 5555, transport: "tcp"]

  def create(idx, host, port, transport) do
    f = fn ->
      :mnesia.write(
        :endpoints,
        endpoint(
          idx: idx,
          host: host,
          port: port,
          transport: transport
        ),
        :write
      )
    end
    :mnesia.activity(:transaction, f)
  end

  def read(idx) do
    f = fn ->
      :mnesia.read(:endpoints, idx)
    end
    [data|_] = :mnesia.activity(:transaction, f)
    endpoint(data)
  end

  def read_all do
    # match_spec generated with :ets.fun2ms(fn(x) -> x end)
    f = fn ->
      :mnesia.select(:endpoints, [{:"$1", [], [:"$1"]}])
    end
    :mnesia.activity(:transaction, f)
    |> Enum.map(fn(data) -> endpoint(data) end)
  end
end
