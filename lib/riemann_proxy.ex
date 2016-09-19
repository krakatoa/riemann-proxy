defmodule RiemannProxy do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    :mnesia.start()
    :ok = :mnesia.wait_for_tables([:endpoints, :routes, :endpoint_connections, :route_bindings], 5000)

    children = [
      supervisor(Task.Supervisor, [[name: RiemannProxy.TaskSupervisor]]),
      worker(Task, [RiemannProxy.Server, :accept, [6782]])
    ]

    opts = [strategy: :one_for_one, name: RiemannProxy.Supervisor]
    Supervisor.start_link(children, opts)
    RiemannProxy.Router.start_link
  end
end
