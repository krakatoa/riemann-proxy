defmodule RiemannProxy.Ping do
  def ping(host, port) do
    :gen_tcp.connect(host, port, [:binary, packet: 4, active: false, send_timeout: 2000], 2000)
    |> try_send
  end

  defp try_send({:error, _reason}), do: false
  defp try_send({:ok, socket}) do
    query = RiemannProxy.Proto.Query.new(string: 'service = "riemann.ping"')
    msg = RiemannProxy.Proto.Msg.encode(RiemannProxy.Proto.Msg.new(query: query))
    :ok = :gen_tcp.send(socket, msg)
    case :gen_tcp.recv(socket, 0) do
      {:ok, _resp} -> true # Proto.Msg.decode(resp)
      _ -> false
    end
  end
end
