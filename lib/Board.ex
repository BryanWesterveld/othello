defmodule OthelloEngine.Board do
    @moduledoc """
    The Board module holds the state of an Othello game. The grid is modelled
    as a dictionary with the rows and columns as keys. To keep track of who
    owns what cell, an atom for the colour is used. The history keeps track
    of all moves to help with debugging or exporting a game.
    """

    defstruct grid: :none, history: :none

    alias OthelloEngine.Board


    defp key(row, col) do
        String.to_atom("#{row}#{col}")
    end


    defp keys() do
        for row <- 1..8, col <- 1..8 do
            key(row, col)
        end
    end


    @doc """
    Initializes a new grid with only the center stones placed.
    """
    def init_grid() do
        Enum.reduce(keys(), %{}, fn(key, grid) ->
            Map.put_new(grid, key, :none)
        end)
        |> Map.update!(key("4", "4"), fn _ -> :white end)
        |> Map.update!(key("4", "5"), fn _ -> :black end)
        |> Map.update!(key("5", "4"), fn _ -> :black end)
        |> Map.update!(key("5", "5"), fn _ -> :white end)
    end


    @doc """
    Starts an agent to keep track of the board.
    """
    def start_link() do
        Agent.start_link(fn -> %Board{grid: init_grid(), history: []} end)
    end


    defp string_coordinate(grid, row, col) do
        case Map.get(grid, key(row, col)) do
            :black -> "●"
            :white -> "○"
            _      -> " "
        end
    end


    defp to_string_row(grid, row) do
        str = Enum.map(1..8, fn col -> string_coordinate(grid, row, col) end)
        |> Enum.join(" | ")
        |> Kernel.<>(" |")
        |> Kernel.<>("\n+---+---+---+---+---+---+---+---+\n")

        "| " <> str
    end


    @doc """
    Converts the entire grid to a string. Used to print the state of the game
    for debugging. A hollow circle is used to represent white stones, a filled
    circle is used to represent black stones.
    """
    def to_string(board_pid) do
        grid = Agent.get(board_pid, fn state -> state.grid end)

        str = Enum.map(1..8, fn row -> to_string_row(grid, row) end)
        |> Enum.join("")

        "+---+---+---+---+---+---+---+---+\n" <> str
    end
end