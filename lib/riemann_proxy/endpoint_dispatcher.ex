defmodule RiemannProxy.EndpointDispatcher do
  require Record
  Record.defrecord :endpoint_dispatcher, [:idx, :pid]

  use GenServer

  def init({host, port}) do
    {:ok, socket} = connect(host, port)
    IO.puts "endpoint dispatcher for #{inspect {host, port}} created @ #{inspect self}"
    {:ok, socket}
  end

  defp connect(host, port) do
    :gen_tcp.connect(host, port, [:binary, packet: 4, active: false, send_timeout: 2000], 2000)
    # {:error, _reason}
  end

  def handle_cast({:dispatch, msg}, socket) do
    IO.puts "dispatch: #{inspect msg} (#{inspect socket}) @ #{inspect self}"
    :ok = :gen_tcp.send(socket, msg)
    {:ok, _resp} = :gen_tcp.recv(socket, 0)

    {:noreply, socket}
  end

  def create(idx, pid) do
    f = fn ->
      :mnesia.write(
        :endpoint_dispatchers,
        endpoint_dispatcher(
          idx: idx,
          pid: pid
        ),
        :write
      )
    end
    :mnesia.activity(:transaction, f)
  end

  def read(idx) do
    f = fn ->
      :mnesia.read(:endpoint_dispatchers, idx)
    end
    case List.first(:mnesia.activity(:transaction, f)) do
      nil -> nil
      data -> endpoint_dispatcher(data)
    end
  end
end
