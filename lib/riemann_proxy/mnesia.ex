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

    :mnesia.create_table(:endpoint_dispatchers, [
      {:attributes, [:idx, :pid]},
      {:type, :set},
      {:record_name, :endpoint_dispatcher},
      {:local_content, true}
    ])
  end

  def multi_stop do
    :rpc.multicall([node()], :application, :stop, [:mnesia])
  end
end
