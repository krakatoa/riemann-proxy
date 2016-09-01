defmodule RiemannProxy.Router do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, {}, [{:name, {:local, __MODULE__}}])
  end

  def init({}) do
    RiemannProxy.EndpointWatcher.start_link
    RiemannProxy.RouteWatcher.start_link
    {:ok, {}}
  end

  def route(msg) do
    decoded_msg = RiemannProxy.Proto.Msg.decode(msg)
    pid = get_pid(decoded_msg)
    IO.puts "Forwarding message to endpoint pid: #{inspect pid}"
    GenServer.cast(__MODULE__, {:route, msg, pid})
  end

  def get_pid(msg) do
    [event|_] = msg.events
    route_lookup(event)
    # event.service
  end

  def route_lookup(event) do
    route_bindings = RiemannProxy.RouteBinding.read_all
    route_lookup(event, route_bindings)
  end

  def route_lookup(_, []) do
    nil
  end

  def route_lookup(event, route_bindings) do
    [head|tail] = route_bindings
    IO.puts "TRACE |   checking if event #{inspect event} matches binding #{inspect head}"
    [matches] = RiemannProxy.RouteMatcher.match?(head[:route_matcher_pid], event)
    case matches do
      true ->
        IO.puts "TRACE |   found match: #{inspect head}"
        head[:endpoint_connection_pid]
      false -> route_lookup(event, tail)
    end
  end

  # def test(tags) do
  #   m = compile_pattern("tagged 'bla'")
  #   Code.eval_quoted(m, [tags: tags])
  # end

  def handle_cast({:route, msg, pid}, state) do
    case pid do
      nil -> 'err'
      _ -> GenServer.cast(pid, {:dispatch, msg})
    end
    {:noreply, state}
  end
end
