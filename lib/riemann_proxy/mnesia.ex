defmodule RiemannProxy.Mnesia do
  def setup do
    nodes = Node.list ++ [node()]
    :ok = :mnesia.create_schema(nodes)
    :mnesia.start()

    # :application.set_env(:mnesia, :dir, 'priv_dir')

    :mnesia.create_table(:endpoints, [
      {:attributes, [:idx, :host, :port, :transport]},
      {:type, :ordered_set},
      {:record_name, :endpoint},
      {:disc_copies, nodes}
    ])

    :mnesia.create_table(:routes, [
      {:attributes, [:order, :pattern, :endpoint_id]},
      {:type, :ordered_set},
      {:record_name, :route},
      {:disc_copies, nodes}
    ])

    :mnesia.create_table(:endpoint_connections, [
      {:attributes, [:idx, :pid]},
      {:type, :set},
      {:record_name, :endpoint_connection},
      {:local_content, true}
    ])

    :mnesia.create_table(:route_bindings, [
      {:attributes, [:order, :route_matcher_pid, :endpoint_connection_pid]},
      {:type, :ordered_set},
      {:record_name, :route_binding},
      {:local_content, true}
    ])
  end

  def multi_stop do
    :rpc.multicall([node()], :application, :stop, [:mnesia])
  end
end
