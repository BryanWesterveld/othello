defmodule BoardTest do
    use ExUnit.Case

    alias OthelloEngine.Board


    test "Starting a board" do
        {:ok, pid} = Board.start_link()

        assert Board.get_grid_cell_value(pid, 4, 4) == :white
        assert Board.get_grid_cell_value(pid, 4, 5) == :black
        assert Board.get_grid_cell_value(pid, 5, 4) == :black
        assert Board.get_grid_cell_value(pid, 5, 5) == :white

        assert Board.can_move?(pid, :black)
        assert Board.can_move?(pid, :white)

        assert Board.get_winner(pid) == :no_winner
    end


    test "Illegal moves" do
        {:ok, pid} = Board.start_link()

        assert Board.make_move(pid, 1, 1, :black) == :not_possible
        assert Board.make_move(pid, 4, 4, :black) == :not_possible
        assert Board.make_move(pid, 4, 5, :black) == :not_possible
        assert Board.make_move(pid, 3, 3, :black) == :not_possible

        assert Board.make_move(pid, 1, 1, :white) == :not_possible
        assert Board.make_move(pid, 4, 4, :white) == :not_possible
        assert Board.make_move(pid, 4, 5, :white) == :not_possible
        assert Board.make_move(pid, 3, 3, :white) == :not_possible
    end


    test "Legal moves" do
        {:ok, pid} = Board.start_link()

        assert Board.make_move(pid, 3, 4, :black) != []
        assert Board.get_grid_cell_value(pid, 3, 4) == :black

        assert Board.make_move(pid, 5, 3, :white) != []
        assert Board.get_grid_cell_value(pid, 5, 3) == :white

        assert Board.can_move?(pid, :black)
        assert Board.can_move?(pid, :white)
    end


    test "No more legal moves" do
        {:ok, pid} = Board.start_link()

        assert Board.make_move(pid, 3, 4, :black) != []
        assert Board.get_grid_cell_value(pid, 3, 4) == :black

        assert Board.make_move(pid, 6, 5, :black) != []
        assert Board.get_grid_cell_value(pid, 6, 5) == :black

        refute Board.can_move?(pid, :black)
        refute Board.can_move?(pid, :white)
        assert Board.get_winner(pid) == :black
    end


    test "Reset" do
        {:ok, pid} = Board.start_link()

        assert Board.make_move(pid, 3, 4, :black) != []
        assert Board.get_grid_cell_value(pid, 3, 4) == :black

        assert Board.make_move(pid, 6, 5, :black) != []
        assert Board.get_grid_cell_value(pid, 6, 5) == :black

        assert Board.get_winner(pid) == :black
        assert Board.reset(pid) == :ok

        assert Board.get_grid_cell_value(pid, 3, 4) == :none
        assert Board.get_grid_cell_value(pid, 6, 5) == :none
        assert Board.get_winner(pid) == :no_winner

    end


    test "Available moves" do
        {:ok, pid} = Board.start_link()

        assert Board.get_possible_moves(pid, :black) == ["34", "43", "56", "65"]
    end


    test "String representation" do
        {:ok, pid} = Board.start_link()

        assert Board.to_string(pid) == """
        +---+---+---+---+---+---+---+---+
        |   |   |   |   |   |   |   |   |
        +---+---+---+---+---+---+---+---+
        |   |   |   |   |   |   |   |   |
        +---+---+---+---+---+---+---+---+
        |   |   |   |   |   |   |   |   |
        +---+---+---+---+---+---+---+---+
        |   |   |   | ○ | ● |   |   |   |
        +---+---+---+---+---+---+---+---+
        |   |   |   | ● | ○ |   |   |   |
        +---+---+---+---+---+---+---+---+
        |   |   |   |   |   |   |   |   |
        +---+---+---+---+---+---+---+---+
        |   |   |   |   |   |   |   |   |
        +---+---+---+---+---+---+---+---+
        |   |   |   |   |   |   |   |   |
        +---+---+---+---+---+---+---+---+
        """
    end


    test "Full game" do
        {:ok, pid} = Board.start_link()

        # Move 1 - 10.
        assert Board.make_move(pid, 5, 6, :black) != []
        assert Board.make_move(pid, 6, 6, :white) != []
        assert Board.make_move(pid, 6, 5, :black) != []
        assert Board.make_move(pid, 4, 6, :white) != []
        assert Board.make_move(pid, 3, 5, :black) != []
        assert Board.make_move(pid, 5, 3, :white) != []
        assert Board.make_move(pid, 4, 3, :black) != []
        assert Board.make_move(pid, 7, 5, :white) != []
        assert Board.make_move(pid, 6, 3, :black) != []
        assert Board.make_move(pid, 2, 5, :white) != []

        # Move 11 - 20.
        assert Board.make_move(pid, 3, 6, :black) != []
        assert Board.make_move(pid, 2, 6, :white) != []
        assert Board.make_move(pid, 4, 7, :black) != []
        assert Board.make_move(pid, 5, 7, :white) != []
        assert Board.make_move(pid, 5, 8, :black) != []
        assert Board.make_move(pid, 6, 4, :white) != []
        assert Board.make_move(pid, 7, 4, :black) != []
        assert Board.make_move(pid, 5, 2, :white) != []
        assert Board.make_move(pid, 8, 6, :black) != []
        assert Board.make_move(pid, 3, 2, :white) != []

        # Move 21 - 30.
        assert Board.make_move(pid, 6, 2, :black) != []
        assert Board.make_move(pid, 3, 4, :white) != []
        assert Board.make_move(pid, 6, 7, :black) != []
        assert Board.make_move(pid, 8, 4, :white) != []
        assert Board.make_move(pid, 8, 3, :black) != []
        assert Board.make_move(pid, 8, 5, :white) != []
        assert Board.make_move(pid, 3, 3, :black) != []
        assert Board.make_move(pid, 7, 6, :white) != []
        assert Board.make_move(pid, 3, 1, :black) != []
        assert Board.make_move(pid, 6, 1, :white) != []

        # State after move 30.
        assert Board.to_string(pid) == """
        +---+---+---+---+---+---+---+---+
        |   |   |   |   |   |   |   |   |
        +---+---+---+---+---+---+---+---+
        |   |   |   |   | ○ | ○ |   |   |
        +---+---+---+---+---+---+---+---+
        | ● | ● | ● | ○ | ○ | ○ |   |   |
        +---+---+---+---+---+---+---+---+
        |   |   | ● | ● | ● | ○ | ● |   |
        +---+---+---+---+---+---+---+---+
        |   | ○ | ● | ○ | ● | ○ | ● | ● |
        +---+---+---+---+---+---+---+---+
        | ○ | ○ | ○ | ○ | ○ | ○ | ● |   |
        +---+---+---+---+---+---+---+---+
        |   |   |   | ○ | ○ | ○ |   |   |
        +---+---+---+---+---+---+---+---+
        |   |   | ● | ○ | ○ | ● |   |   |
        +---+---+---+---+---+---+---+---+
        """

        assert Board.can_move?(pid, :black)
        assert Board.can_move?(pid, :white)
        assert Board.get_winner(pid) == :no_winner

        # Move 31 - 40.
        assert Board.make_move(pid, 2, 3, :black) != []
        assert Board.make_move(pid, 4, 8, :white) != []
        assert Board.make_move(pid, 1, 5, :black) != []
        assert Board.make_move(pid, 4, 2, :white) != []
        assert Board.make_move(pid, 6, 8, :black) != []
        assert Board.make_move(pid, 3, 7, :white) != []
        assert Board.make_move(pid, 7, 7, :black) != []
        assert Board.make_move(pid, 1, 3, :white) != []
        assert Board.make_move(pid, 1, 4, :black) != []
        assert Board.make_move(pid, 1, 6, :white) != []

        # Move 41 - 50.
        assert Board.make_move(pid, 8, 7, :black) != []
        assert Board.make_move(pid, 2, 4, :white) != []
        assert Board.make_move(pid, 5, 1, :black) != []
        assert Board.make_move(pid, 1, 2, :white) != []
        assert Board.make_move(pid, 4, 1, :black) != []
        assert Board.make_move(pid, 2, 1, :white) != []
        assert Board.make_move(pid, 2, 7, :black) != []
        assert Board.make_move(pid, 2, 2, :white) != []
        assert Board.make_move(pid, 1, 1, :black) != []
        assert Board.make_move(pid, 8, 8, :white) != []

        # Move 51 - 60.
        assert Board.make_move(pid, 3, 8, :black) != []
        assert Board.make_move(pid, 2, 8, :white) != []
        assert Board.make_move(pid, 7, 3, :black) != []
        assert Board.make_move(pid, 7, 8, :white) != []
        assert Board.make_move(pid, 7, 1, :black) != []

        assert Board.make_move(pid, 7, 2, :white) != []
        assert Board.make_move(pid, 8, 2, :black) != []
        assert Board.make_move(pid, 8, 1, :white) != []
        assert Board.make_move(pid, 1, 7, :black) != []
        assert Board.make_move(pid, 1, 8, :white) != []

        # State after all legal moves.
        assert Board.to_string(pid) == """
        +---+---+---+---+---+---+---+---+
        | ● | ● | ● | ● | ● | ● | ● | ○ |
        +---+---+---+---+---+---+---+---+
        | ● | ● | ○ | ○ | ○ | ● | ○ | ○ |
        +---+---+---+---+---+---+---+---+
        | ● | ● | ● | ○ | ● | ○ | ● | ○ |
        +---+---+---+---+---+---+---+---+
        | ● | ● | ● | ● | ○ | ○ | ● | ○ |
        +---+---+---+---+---+---+---+---+
        | ● | ● | ● | ○ | ● | ○ | ● | ○ |
        +---+---+---+---+---+---+---+---+
        | ● | ● | ○ | ● | ● | ● | ○ | ○ |
        +---+---+---+---+---+---+---+---+
        | ● | ○ | ● | ○ | ○ | ○ | ○ | ○ |
        +---+---+---+---+---+---+---+---+
        | ○ | ○ | ○ | ○ | ○ | ○ | ○ | ○ |
        +---+---+---+---+---+---+---+---+
        """

        refute Board.can_move?(pid, :black)
        refute Board.can_move?(pid, :white)
        assert Board.get_winner(pid) == :tie
    end
end