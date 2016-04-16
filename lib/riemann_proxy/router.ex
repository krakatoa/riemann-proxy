defmodule RiemannProxy.Router do
  require RiemannProxy.Endpoint

  def fake_route(msg) do
    {host, port} = select_host
    :gen_tcp.connect(host, port, [:binary, packet: 4, active: false, send_timeout: 2000], 2000)
    |> forward(msg)
  end

  defp forward({:error, _reason}, _msg), do: false
  defp forward({:ok, socket}, msg) do
    :ok = :gen_tcp.send(socket, msg)
    {:ok, _resp} = :gen_tcp.recv(socket, 0)
  end

  defp select_host do
    [data|_] = RiemannProxy.Endpoint.read_all
    endpoint = RiemannProxy.Endpoint.endpoint(data)
    {endpoint[:host], endpoint[:port]}
  end
end
