defmodule OthelloEngine.Player do
    defstruct name: :none, color: :none

    alias OthelloEngine.Player


    def start_link(color, name \\ :none) do
        Agent.start_link(fn -> %Player{color: color, name: name} end)
    end


    def set_name(player_pid, name) do
        Agent.update(player_pid, fn state -> Map.put(state, :name, name) end)
    end


    def set_color(player_pid, color) do
        Agent.update(player_pid, fn state -> Map.put(state, :color, color) end)
    end


    def get_color(player_pid) do
        Agent.get(player_pid, fn state -> state.color end)
    end


    def get_name(player_pid) do
        Agent.get(player_pid, fn state -> state.name end)
        |> name_to_string()
    end


    def flip_color(player_pid) do
        Agent.update(player_pid, fn state ->
            Map.put(state, :color, opposite_color(state.color))
        end)
    end


    defp name_to_string(:none) do
        "Anonymous"
    end

    defp name_to_string(name) do
        ~s("#{name}")
    end


    defp opposite_color(:white) do
        :black
    end

    defp opposite_color(:black) do
        :white
    end

end