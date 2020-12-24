defmodule OthelloEngine.GameSupervisor do
    use DynamicSupervisor

    alias OthelloEngine.Game


    def start_link(_options) do
        DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
    end


    def init(:ok) do
        DynamicSupervisor.init(max_children: 1000, strategy: :one_for_one)
    end


    def start_game(game_id, name) do
        spec = %{id: Game, start: {Game, :start_link, [game_id, name]},
                 restart: :temporary}
        DynamicSupervisor.start_child(__MODULE__, spec)
    end


    def stop_game(game_id) do
        case pid_from_id(game_id) do
            {:ok, pid}       -> DynamicSupervisor.terminate_child(__MODULE__, pid)
            {:error, reason} -> reason
            _                -> :error
        end
    end


    def pid_from_id(game_id) do
        pid = game_id
        |> Game.via_tuple()
        |> GenServer.whereis()

        case pid do
            nil -> {:error, :no_game}
            _   -> {:ok, pid}
        end
    end
end