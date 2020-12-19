defmodule OthelloEngine.History do
    @moduledoc """
    The History module holds the history of an Othello game. Used for debugging
    and exporting games.
    """

    @indices ~w(1 2 3 4 5 6 7 8)


    @doc """
    Starts an agent to keep track of the history.
    """
    def start_link() do
        Agent.start_link(fn -> [] end)
    end


    @doc """
    Resets the history.
    """
    def reset(history_pid) do
        Agent.update(history_pid, fn _ -> [] end)
    end


    @doc """
    Returns the current history. Used for debugging or exporting the state.
    """
    def get_history(history_pid) do
        Agent.get(history_pid, fn state -> state end)
    end


    @doc """
    Adds the move to the history of moves. If an invalid index is given, an
    error is thrown.
    """
    def add_move(history_pid, row, col, color)
        when row in @indices and col in @indices do
        Agent.update(history_pid, fn state -> state ++ [{row, col, color}] end)
    end

    def add_move(history_pid, row, col, color)
        when row in 1..8 and col in 1..8  do
        Agent.update(history_pid, fn state -> state ++ [{row, col, color}] end)
    end
end