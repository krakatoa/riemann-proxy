# RiemannProxy

The main motivation behind writing a Riemann Proxy relies in the fact that handling lots of metrics and calculations can lead in asymetric topology of several Riemann servers scattering and gathering subsets of information to take different responsibilities over each subset (ie.: making partials, moving averages, alerting, etc.). Also, there are the following motivations behind Riemann-Proxy:

* Single and symmetric configuration
* Automatically ring-failover on Riemann servers
* Put into practice various Erlang VM and Elixir stuff in a real production environment

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add riemann_proxy to your list of dependencies in `mix.exs`:

        def deps do
          [{:riemann_proxy, "~> 0.0.1"}]
        end

  2. Ensure riemann_proxy is started before your application:

        def application do
          [applications: [:riemann_proxy]]
        end

