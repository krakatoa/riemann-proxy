defmodule RiemannProxy do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    :mnesia.start()

    children = [
      supervisor(Task.Supervisor, [[name: RiemannProxy.TaskSupervisor]]),
      worker(Task, [RiemannProxy.Server, :accept, [6782]])
    ]

    opts = [strategy: :one_for_one, name: RiemannProxy.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
