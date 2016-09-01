defmodule RiemannProxy.Route do
  require Record
  Record.defrecord :route, [:order, :pattern, :endpoint_id]

  def create(order, pattern, endpoint_id) do
    f = fn ->
      :mnesia.write(
        :routes,
        route(
          order: order,
          pattern: pattern,
          endpoint_id: endpoint_id
        ),
        :write
      )
    end
    :mnesia.activity(:transaction, f)
  end

  def read_all do
    f = fn ->
      :mnesia.select(:routes, [{:"$1", [], [:"$1"]}])
    end
    :mnesia.activity(:transaction, f)
    |> Enum.map(fn(data) -> route(data) end)
  end
end
