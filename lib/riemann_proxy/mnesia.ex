defmodule RiemannProxy.Mnesia do
  def setup do
    :ok = :mnesia.create_schema([node()])
    :mnesia.start()

    # :application.set_env(:mnesia, :dir, 'priv_dir')

    :mnesia.create_table(:endpoints, [
      {:attributes, [:idx, :host, :port, :transport]},
      {:type, :ordered_set},
      {:record_name, :endpoint},
      {:disc_copies, [node()]}
    ])
  end

  def multi_stop do
    :rpc.multicall([node()], :application, :stop, [:mnesia])
  end
end
