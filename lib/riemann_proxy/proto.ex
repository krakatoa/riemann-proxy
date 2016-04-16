defmodule RiemannProxy.Proto do
  use Protobuf, from: Path.expand("../../riemann.proto", __DIR__)
end
