defmodule OthelloEngineTest do
  use ExUnit.Case
  doctest OthelloEngine

  test "greets the world" do
    assert OthelloEngine.hello() == :world
  end
end
