defmodule RiemannProxy.EndpointConnection do
  require Record
  Record.defrecord :endpoint_connection, [:idx, :pid]
  # local_content

  use GenServer

  def init({host, port}) do
    {:ok, socket} = connect(host, port)
    IO.puts "endpoint connection for #{inspect {host, port}} created @ #{inspect self}"
    {:ok, socket}
  end

  defp connect(host, port) do
    :gen_tcp.connect(host, port, [:binary, packet: 4, active: false, send_timeout: 2000], 2000)
    # {:error, _reason}
  end

  def handle_cast({:dispatch, msg}, socket) do
    IO.puts "Dispatch: #{inspect msg} (#{inspect socket}) @ #{inspect self}"
    :ok = :gen_tcp.send(socket, msg)
    {:ok, _resp} = :gen_tcp.recv(socket, 0)

    {:noreply, socket}
  end

  def register(idx, pid) do
    f = fn ->
      :mnesia.write(
        :endpoint_connections,
        endpoint_connection(
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
      :mnesia.read(:endpoint_connections, idx)
    end
    case List.first(:mnesia.activity(:transaction, f)) do
      nil -> nil
      data -> endpoint_connection(data)
    end
  end
end
