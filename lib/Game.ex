defmodule OthelloEngine.Game do
    use GenServer
    alias OthelloEngine.{Board, History, Game, Player, Rules}

    defstruct board: :none, history: :none, playerA: :none, playerB: :none, fsm: :none


    def start_link(game_id, name) when not is_nil(game_id) and not is_nil(name) do
        GenServer.start_link(__MODULE__, name, name: {:global, "game:othello:#{game_id}"})
    end


    def init(name) do
        {:ok, board} = Board.start_link()
        {:ok, history} = History.start_link()
        {:ok, playerA} = Player.start_link(:black, name)
        {:ok, playerB} = Player.start_link(:white)
        {:ok, fsm} = Rules.start_link()

        {:ok, %Game{board: board, history: history,
                    playerA: playerA, playerB: playerB, fsm: fsm}}
    end


    def add_player(game_pid, name) when not is_nil(name) do
        GenServer.call(game_pid, {:add_player, name})
    end


    def make_move(game_pid, player, row, col) when is_atom player do
        GenServer.call(game_pid, {:make_move, player, row, col})
    end


    def get_winner(game_pid) do
        GenServer.call(game_pid, {:get_winner})
    end


    def stop(game_pid) do
        GenServer.cast(game_pid, :stop)
    end


    def handle_cast(:stop, state) do
        {:stop, :normal, state}
    end


    def handle_call({:get_winner}, _from, state) do
        winner = Board.get_winner(state.board)
        {:reply, winner, state}
    end


    def handle_call({:add_player, name}, _from, state) do
        Player.set_name(state.playerB, name)
        {:reply, :ok, state}
    end


    def handle_call({:make_move, player, row, col}, _from, state) do
        player_pid = Map.get(state, player)
        color = Player.get_color(player_pid)

        Board.make_move(state.board, row, col, color)
        |> log_move(player, state, row, col)
        |> pass_check(player, state)
        |> win_check(player, state)
        |> possible_moves_check(player, state)
    end


    defp log_move(:not_possible, _player, _state, _row, _col) do
        :not_possible
    end

    defp log_move(pieces, player, state, row, col) do
        player_pid = Map.get(state, player)
        color = Player.get_color(player_pid)

        History.add_move(state.history, row, col, color)
        pieces
    end


    defp pass_check(:not_possible, _player, _state) do
        {:not_possible, :no_pass}
    end

    defp pass_check(pieces, player, state) do
        player_pid = Map.get(state, opposite_player(player))
        color = Player.get_color(player_pid)

        pass_status =
        case Board.can_move?(state.board, color) do
            true    -> :no_pass
            false   -> :pass
        end

        {pieces, pass_status}
    end


    defp win_check({pieces, :no_pass}, _player, _state) do
       {pieces, :no_pass, :no_win}
    end

    defp win_check({pieces, :pass}, player, state) do
        player_pid = Map.get(state, player)
        color = Player.get_color(player_pid)

        win_status =
        case Board.can_move?(state.board, color) do
            true    -> :no_win
            false   -> :win
        end

        {pieces, :pass, win_status}
    end


    defp possible_moves_check({:not_possible, pass, win}, player, state) do
        player_pid = Map.get(state, player)
        color = Player.get_color(player_pid)
        moves = Board.get_possible_moves(state.board, color)

        {:reply, {:not_possible, pass, win, moves}, state}
    end


    defp possible_moves_check({pieces, :pass, :win}, _player, state) do
        {:reply, {pieces, :pass, :win, []}, state}
    end

    defp possible_moves_check({pieces, :pass, win}, player, state) do
        player_pid = Map.get(state, player)
        color = Player.get_color(player_pid)
        moves = Board.get_possible_moves(state.board, color)

        {:reply, {pieces, :pass, win, moves}, state}
    end

    defp possible_moves_check({pieces, :no_pass, win}, player, state) do
        player_pid = Map.get(state, opposite_player(player))
        color = Player.get_color(player_pid)
        moves = Board.get_possible_moves(state.board, color)

        {:reply, {pieces, :no_pass, win, moves}, state}
    end


    defp opposite_player(:playerA) do
        :playerB
    end

    defp opposite_player(:playerB) do
        :playerA
    end
end