defmodule RiemannProxy.Router do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, {}, [{:name, {:local, __MODULE__}}])
  end

  def init({}) do
    RiemannProxy.EndpointWatcher.start_link
    {:ok, {}}
  end

  def route(msg, idx) do
    GenServer.cast(__MODULE__, {:route, msg, idx})
  end

  def handle_cast({:route, msg, idx}, state) do
    pid = RiemannProxy.EndpointDispatcher.read(idx)[:pid]
    case pid do
      nil -> 'err'
      _ -> GenServer.cast(pid, {:dispatch, msg})
    end
    {:noreply, state}
  end
end
