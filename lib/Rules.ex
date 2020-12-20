defmodule OthelloEngine.Rules do
    @behaviour :gen_statem

    alias OthelloEngine.Rules

    defstruct black: :rematch_pending, white: :rematch_pending


    def start_link() do
        :gen_statem.start_link(__MODULE__, :ok, [])
    end


    def init(:ok) do
        {:ok, :initialized, %Rules{}}
    end


    def callback_mode() do
        :state_functions
    end


    def add_player(fsm_pid) do
        :gen_statem.call(fsm_pid, :add_player)
    end


    def make_move(fsm_pid, color) do
        :gen_statem.call(fsm_pid, {:make_move, color})
    end


    def win(fsm_pid) do
        :gen_statem.call(fsm_pid, :win)
    end


    def pass(fsm_pid, color) do
        :gen_statem.call(fsm_pid, {:pass, color})
    end


    def rematch(fsm_pid, color) do
        :gen_statem.call(fsm_pid, {:rematch, color})
    end


    def show_current_state(fsm_pid) do
        :gen_statem.call(fsm_pid, :show_current_state)
    end


    def initialized({:call, from}, :show_current_state, _state_data) do
        {:keep_state_and_data, {:reply, from, :initialized}}
    end

    def initialized({:call, from}, :add_player, state_data) do
        {:next_state, :black_turn, state_data, {:reply, from, :ok}}
    end

    def initialized({:call, from}, _, _state_data) do
        {:keep_state_and_data, {:reply, from, :error}}
    end


    def black_turn({:call, from}, :show_current_state, _state_data) do
        {:keep_state_and_data, {:reply, from, :black_turn}}
    end

    def black_turn({:call, from}, {:make_move, :black}, state_data) do
        {:next_state, :white_turn, state_data, {:reply, from, :ok}}
    end

    def black_turn({:call, from}, :win, state_data) do
        {:next_state, :game_over, state_data, {:reply, from, :ok}}
    end

    def black_turn({:call, from}, {:pass, :black}, state_data) do
        {:next_state, :white_turn, state_data, {:reply, from, :ok}}
    end

    def black_turn({:call, from}, _, _state_data) do
       {:keep_state_and_data, {:reply, from, :error}}
    end


    def white_turn({:call, from}, :show_current_state, _state_data) do
        {:keep_state_and_data, {:reply, from, :white_turn}}
    end

    def white_turn({:call, from}, {:make_move, :white}, state_data) do
        {:next_state, :black, state_data, {:reply, from, :ok}}
    end

    def white_turn({:call, from}, :win, state_data) do
        {:next_state, :game_over, state_data, {:reply, from, :ok}}
    end

    def white_turn({:call, from}, {:pass, :white}, state_data) do
        {:next_state, :black_turn, state_data, {:reply, from, :ok}}
    end

    def white_turn({:call, from}, _, _state_data) do
       {:keep_state_and_data, {:reply, from, :error}}
    end


    def game_over({:call, from}, :show_current_state, _state_data) do
        {:keep_state_and_data, {:reply, from, :game_over}}
    end

    def game_over({:call, from}, {:rematch, color}, state_data) do
        state_data = Map.put(state_data, color, :rematch_accepted)
        game_over_reply(from, state_data, state_data.black, state_data.white)
    end

    def game_over({:call, from}, _, _state_data) do
        {:keep_state_and_data, {:reply, from, :error}}
    end

    defp game_over_reply(from, _state_data, status, status)
        when status == :rematch_accepted do
        {:next_state, :initialized, %Rules{}, {:reply, from, :ok}}
    end

    defp game_over_reply(from, state_data, _, _) do
        {:keep_state, state_data, {:reply, from, :ok}}
    end
end