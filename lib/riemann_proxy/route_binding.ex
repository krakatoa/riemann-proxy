defmodule RiemannProxy.RouteBinding do
  require Record
  Record.defrecord :route_binding, [:order, :route_matcher_pid, :endpoint_connection_pid]
  # local_content

  def register(order, route_matcher_pid, endpoint_connection_pid) do
    f = fn ->
      :mnesia.write(
        :route_bindings,
        route_binding(
          order: order,
          route_matcher_pid: route_matcher_pid,
          endpoint_connection_pid: endpoint_connection_pid
        ),
        :write
      )
    end
    :mnesia.activity(:transaction, f)
  end

  def read_all do
    # match_spec generated with :ets.fun2ms(fn(x) -> x end)
    f = fn ->
      :mnesia.select(:route_bindings, [{:"$1", [], [:"$1"]}])
    end
    :mnesia.activity(:transaction, f)
    |> Enum.map(fn(data) -> route_binding(data) end)
  end
end
