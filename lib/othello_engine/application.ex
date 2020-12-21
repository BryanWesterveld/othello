defmodule OthelloEngine.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: OthelloEngine.Worker.start_link(arg)
      # {OthelloEngine.Worker, arg}
      {Registry, keys: :unique, name: Registry.Game},
      OthelloEngine.GameSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OthelloEngine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
