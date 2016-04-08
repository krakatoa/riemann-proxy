defmodule RiemannProxy.Server do
  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port,
                      [:binary, packet: 4, active: false, reuseaddr: true])

    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(RiemannProxy.TaskSupervisor, fn -> serve(client) end)
    :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    IO.puts "Recv: #{inspect data, limit: 50}"
    Proto.Msg.encode(Proto.Msg.new(ok: true))
  end

  defp write_line(response, socket) do
    :gen_tcp.send(socket, response)
  end

end
