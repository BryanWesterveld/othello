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
        try do
            DynamicSupervisor.terminate_child(__MODULE__, pid_from_id(game_id))
        rescue
            FunctionClauseError -> :no_game
        end
    end


    defp pid_from_id(game_id) do
        game_id
        |> Game.via_tuple()
        |> GenServer.whereis()
    end
end