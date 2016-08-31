defmodule RiemannProxy.RouteMatcher do
  use GenServer

  def start(pattern) do
    GenServer.start(__MODULE__, pattern, [])
  end

  def match?(pid, event) do
    GenServer.call(pid, {:match, event})
  end

  def init(pattern) do
    {:ok, compile_pattern(pattern)}
  end

  defp compile_pattern(pattern) do
    checks = []
    case Regex.run(~r/tagged '(\w+)'/, pattern) do
      [_, tag] ->
        checks = checks ++ [quote do
          IO.puts "TRACE | tags: #{inspect var!(event).tags}"
          # Enum.member?(var!(event).tags, to_char_list(unquote(tag)))
          Enum.member?(var!(event).tags, unquote(tag))
        end]
      nil -> checks
    end
    case Regex.run(~r/service = '(\w+)'/, pattern) do
      [_, service_regex] ->
        {:ok, regex} = Regex.compile(service_regex)
        checks = checks ++ [quote do
          Regex.match?(unquote(Macro.escape(regex)), to_string(var!(event).service))
        end]
      nil -> checks
    end
    checks
  end

  # match?
  # {:ok, pattern} = RiemannProxy.RoutePattern.start("service = 'bla'")
  # RiemannProxy.RoutePattern.match?(pattern, %{service: 'bla', tags: ['tast']})

  def handle_call({:match, event}, _from, matcher) do
    {result, _args} = Code.eval_quoted(matcher, [event: event])
    {:reply, result, matcher}
  end
end
