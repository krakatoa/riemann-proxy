defmodule RiemannProxy.RouteWatcher do
  use GenServer
  require RiemannProxy.Route

  def start_link do
    GenServer.start_link( __MODULE__,
                          {},
                          [ {:name, {:local, __MODULE__}} ] )
  end

  def init({}) do
    prefill
    subscribe
    {:ok, {}}
  end

  defp prefill do
    RiemannProxy.Route.read_all
    |> Enum.each(fn(r) -> spin_route_matcher(r) end)
  end

  def spin_route_matcher(route) do
    {:ok, route_matcher_pid} = GenServer.start(RiemannProxy.RouteMatcher, route[:pattern])
    endpoint_connection_pid = RiemannProxy.EndpointConnection.read(route[:endpoint_id])[:pid]
    RiemannProxy.RouteBinding.register(
      route[:order],
      route_matcher_pid,
      endpoint_connection_pid
    )
  end

  defp subscribe do
    :mnesia.subscribe({:table, :routes, :simple})
  end
end
