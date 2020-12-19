defmodule OthelloEngine.Board do
    @moduledoc """
    The Board module holds the state of an Othello game. The grid is modelled
    as a dictionary with the rows and columns as keys. To keep track of who
    owns what cell, an atom for the colour is used. The history keeps track
    of all moves to help with debugging or exporting a game.
    """

    defstruct grid: :none, history: :none
    @indices ~w(1 2 3 4 5 6 7 8)

    alias OthelloEngine.Board


    ###
    # Converts string or integer indices to an atom. Accepts only legal
    # coordinates to prevent filling up the atom table with dynamically
    # generated atoms.
    defp key(row, col) when row in @indices and col in @indices do
        String.to_atom("#{row}#{col}")
    end

    defp key(row, col) when row in 1..8 and col in 1..8 do
        String.to_atom("#{row}#{col}")
    end


    ###
    # Returns a list of keys to index the board.
    defp keys() do
        for row <- 1..8, col <- 1..8 do
            key(row, col)
        end
    end


    ###
    # Returns the opposite color, either black or white.
    defp opposite_color(:white) do
        :black
    end

    defp opposite_color(:black) do
        :white
    end


    @doc """
    Returns the current state of the board. Used for debugging only.
    """
    def get_state(board_pid) do
        Agent.get(board_pid, fn state -> state.grid end)
    end


    ###
    # Initializes a new grid with only the center stones placed.
    defp init_grid() do
        Enum.reduce(keys(), %{}, fn(key, grid) ->
            Map.put_new(grid, key, :none)
        end)
        |> Map.update!(key("4", "4"), fn _ -> :white end)
        |> Map.update!(key("4", "5"), fn _ -> :black end)
        |> Map.update!(key("5", "4"), fn _ -> :black end)
        |> Map.update!(key("5", "5"), fn _ -> :white end)
    end


    ###
    # Starts an agent to keep track of the board.
    def start_link() do
        Agent.start_link(fn -> %Board{grid: init_grid(), history: []} end)
    end


    ###
    # Recursive helper function to return the cells that would get flipped.
    # Keeps looking until it finds a cell that makes the move legal or returns
    # early with an empty list.
    defp calculate_move_line_r(_cells, :none, _moves) do
        []
    end

    defp calculate_move_line_r([], _color, _moves) do
        []
    end

    defp calculate_move_line_r([{_r, _c, :none} | _tail], _color, _moves) do
        []
    end

    defp calculate_move_line_r([{_r, _c, color} | _tail], color, moves) do
        moves
    end

    defp calculate_move_line_r([head | tail], color, moves) do
        calculate_move_line_r(tail, color, [head | moves])
    end


    ###
    # Returns a list of all the cells that would get flipped in a single
    # line.
    defp calculate_move_line([_center | cells], color) do
        calculate_move_line_r(cells, color, [])
    end


    ###
    # Returns a list of cells that would get flipped in a horizontal line.
    # Checks both to the left and to the right of where the new stone would be
    # placed.
    defp calculate_move_horizontal(grid, row, col, color) do
        with(
            left <- Enum.map(col..1, fn c ->
                        {row, c, Map.get(grid, key(row, c))}
                    end),
            right <- Enum.map(col..8, fn c ->
                        {row, c, Map.get(grid, key(row, c))}
                    end)
        ) do
            calculate_move_line(left, color) ++
            calculate_move_line(right, color)
        end
    end


    ###
    # Returns a list of cells that would get flipped in a vertical line.
    # Checks both up and down of where the new stone would be placed.
    defp calculate_move_vertical(grid, row, col, color) do
        with(
            up <- Enum.map(row..1, fn r ->
                        {r, col, Map.get(grid, key(r, col))}
                    end),
            down <- Enum.map(row..8, fn r ->
                        {r, col, Map.get(grid, key(r, col))}
                    end)
        ) do
            calculate_move_line(up, color) ++
            calculate_move_line(down, color)
        end
    end


    ###
    # Returns valid indices that must be checked to find if a move is legal.
    # Could be refactored as every quadrant is the same with some axis flipped.
    defp get_range(row, col, :top_left) when row >= col do
        0..col-1
    end

    defp get_range(row, col, :top_left) when row < col do
        0..row-1
    end

    defp get_range(row, col, :top_right) when row >= 9-col do
        0..9-col-1
    end

    defp get_range(row, col, :top_right) when row < 9-col do
        0..row-1
    end

    defp get_range(row, col, :bottom_left) when 9 - row >= col do
        0..col-1
    end

    defp get_range(row, col, :bottom_left) when 9 - row < col do
        0..9-row-1
    end

    defp get_range(row, col, :bottom_right) when 9 - row >= 9 - col do
        0..9-col-1
    end

    defp get_range(row, col, :bottom_right) when 9 - row < 9 - col do
        0..9-row-1
    end


    ###
    # Returns a list of cells that would get flipped in a diagonal line. Checks
    # all four direction of where the new stone would be placed. The get_range
    # function is used to get valid indices to prevent converting illegal indices
    # to atoms and filling up the atom table.
    defp calculate_move_diagonal(grid, row, col, color) do
        with(
            tl <- Enum.map(get_range(row, col, :top_left), fn n ->
                        {row - n, col - n, Map.get(grid, key(row - n, col - n))}
                    end),
            tr <- Enum.map(get_range(row, col, :top_right), fn n ->
                        {row - n, col + n, Map.get(grid, key(row - n, col + n))}
                    end),
            bl <- Enum.map(get_range(row, col, :bottom_left), fn n ->
                        {row + n, col - n, Map.get(grid, key(row + n, col - n))}
                    end),
            br <- Enum.map(get_range(row, col, :bottom_right), fn n ->
                        {row + n, col + n, Map.get(grid, key(row + n, col + n))}
                    end)
        ) do
            calculate_move_line(tl, color) ++
            calculate_move_line(tr, color) ++
            calculate_move_line(bl, color) ++
            calculate_move_line(br, color)
        end
    end


    ###
    # Returns the value of a cell.
    defp get_cell_value(grid, row, col) do
        Map.get(grid, key(row, col))
    end


    @doc """
    Returns the value of a cell in the grid.
    """
    def get_grid_cell_value(board_pid, row, col) do
        grid = Agent.get(board_pid, fn state -> state.grid end)

        get_cell_value(grid, row, col)
    end


    @doc """
    Checks if a player has legal moves. If no moves are possible he must pass
    and the game ends when neither player can move. This may be well before
    all 64 stones have been placed.
    """
    def can_move?(board_pid, color) do
        moves = for row <- 1..8, col <- 1..8 do
            calculate_move(board_pid, row, col, color)
        end

        Enum.reduce_while(moves, false, fn move, acc ->
            case move do
                []  -> {:cont, acc}
                _   -> {:halt, true}
            end
        end)
    end


    @doc """
    Gets all the possible moves for a row, column and color. Returns an empty
    list if there are no possible moves.
    """
    def calculate_move(board_pid, row, col, color) do
        grid = Agent.get(board_pid, fn state -> state.grid end)

        case Map.get(grid, key(row, col)) do
            :none -> calculate_move_horizontal(grid, row, col, color) ++
                     calculate_move_vertical(grid, row, col, color) ++
                     calculate_move_diagonal(grid, row, col, color)
            _     -> []
        end
    end


    ###
    # Flips the color of a cell.
    defp flip_piece(board_pid, {row, col, color}) do
        opposite_color = opposite_color(color)

        Agent.update(board_pid,
            fn state -> %{history: [],
                          grid: Map.update!(state.grid, key(row, col),
                                    fn _ -> opposite_color end)}
            end)
    end


    ###
    # Flips the color of a list of cells.
    defp flip_pieces(board_pid, pieces) do
        Enum.map(pieces, fn piece -> flip_piece(board_pid, piece) end)
    end


    ###
    # Updates the state to place a new stone on the board.
    defp set_grid_cell_value(board_pid, row, col, color) do
        Agent.update(board_pid,
            fn state -> %{history: [],
                          grid: Map.update!(state.grid, key(row, col),
                                    fn _ -> color end)}
            end)
    end


    ###
    # Makes a move or returns :not_possible.
    def make_move(board_pid, row, col, color) do
        case calculate_move(board_pid, row, col, color) do
            []      -> :not_possible
            pieces  -> flip_pieces(board_pid, pieces)
                       set_grid_cell_value(board_pid, row, col, color)
        end
    end


    ###
    # Return a string representation of a cell. A filled circle is black and a
    # border is white.
    defp string_coordinate(grid, row, col) do
        case get_cell_value(grid, row, col) do
            :black -> "●"
            :white -> "○"
            :none  -> " "
            _      -> "x"
        end
    end

    ###
    # Return a string representation of a row of cells.
    defp to_string_row(grid, row) do
        str = Enum.map(1..8, fn col -> string_coordinate(grid, row, col) end)
        |> Enum.join(" | ")
        |> Kernel.<>(" |")
        |> Kernel.<>("\n+---+---+---+---+---+---+---+---+\n")

        "| " <> str
    end


    ###
    # Converts the entire grid to a string. Used to print the state of the game
    # for debugging. A hollow circle is used to represent white stones, a filled
    # circle is used to represent black stones.
    def to_string(board_pid) do
        grid = Agent.get(board_pid, fn state -> state.grid end)

        str = Enum.map(1..8, fn row -> to_string_row(grid, row) end)
        |> Enum.join("")

        "+---+---+---+---+---+---+---+---+\n" <> str
    end
end