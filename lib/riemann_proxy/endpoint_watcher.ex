defmodule RiemannProxy.EndpointWatcher do
  use GenServer
  require RiemannProxy.Endpoint

  def start_link do
    GenServer.start_link(__MODULE__, {}, [{:name, {:local, __MODULE__}}])
  end

  def init({}) do
    prefill
    subscribe
    {:ok, {}}
  end

  defp prefill do
    RiemannProxy.Endpoint.read_all
    |> Enum.each(fn(e) -> spin_endpoint(e) end)
  end

  defp subscribe do
    :mnesia.subscribe({:table, :endpoints, :simple})
  end

  defp mnesia_record_to_endpoint(record) do
    Tuple.delete_at(record,0)
    |> Tuple.insert_at(0, :endpoint)
    |> RiemannProxy.Endpoint.endpoint
  end

  defp spin_endpoint(endpoint) do
    {:ok, pid} = GenServer.start(RiemannProxy.EndpointDispatcher, {endpoint[:host], endpoint[:port]}, [])
    RiemannProxy.EndpointDispatcher.create(endpoint[:idx], pid)
  end

  def handle_info({:mnesia_table_event, {:write, record, _d}}, state) do
    record
    |> mnesia_record_to_endpoint
    |> spin_endpoint

    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.puts("mnesia change: #{inspect msg}")
    # GenServer.call(__MODULE__, {:route, {payload, routing_key}})

    {:noreply, state}
  end
end
