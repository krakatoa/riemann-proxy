defmodule RiemannProxy.EndpointConnection do
  require Record
  Record.defrecord :endpoint_connection, [:idx, :pid]
  # local_content

  use Connection

  def init({host, port}) do
    #IO.puts "endpoint connection for #{inspect {host, port}} created @ #{inspect self}"
    {:connect, nil, {host, port, nil}}
  end

  def connect(_info, {host, port, _}) do
    case :gen_tcp.connect(host, port, [:binary, packet: 4, active: false, send_timeout: 2000], 2000) do
      {:ok, socket} ->
        {:ok, {host, port, socket}}
      {:error, reason} ->
        IO.puts "Connection error on host #{host} and port #{port}, reason: #{inspect reason}"
        {:backoff, 5000, {host, port, nil}}
    end
  end

  def disconnect(info, {host, port, socket}) do
    :ok = :gen_tcp.close(socket)
    case info do
      {:close, from} ->
        Connection.reply(from, :ok)
      {:error, :closed} ->
        IO.puts "Connection closed"
      {:error, reason} ->
        reason = :inet.format_error(reason)
        IO.puts "Connection error: #{inspect reason}"
    end
    {:connect, :reconnect, {host, port, socket}}
  end

  def dispatch(endpoint_connection, msg) do
    Connection.cast(endpoint_connection, {:dispatch, msg})
  end

  def handle_cast({:dispatch, msg}, {host, port, socket}) when is_nil(socket) do
    IO.puts "-- discarding message --"
    {:noreply, {host, port, socket}}
  end

  def handle_cast({:dispatch, msg}, {host, port, socket}) do
    IO.puts "Dispatch: #{inspect msg} (#{inspect socket}) @ #{inspect self}"
    case :gen_tcp.send(socket, msg) do
      :ok ->
        case :gen_tcp.recv(socket, 0) do
          {:ok, _resp} ->
            {:noreply, {host, port, socket}}
          {:error, :timeout} ->
            IO.puts "dispatch recv timeout"
            {:noreply, {host, port, socket}}
          {:error, _} = error ->
            IO.puts "dispatch recv error"
            {:disconnect, error, {host, port, socket}}
        end
      {:error, _} = error ->
        IO.puts "dispatch send error"
        {:disconnect, error, {host, port, socket}}
    end
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
