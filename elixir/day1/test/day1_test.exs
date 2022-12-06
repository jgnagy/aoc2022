defmodule Day1Test do
  use ExUnit.Case
  doctest Day1

  test "greets the world" do
    assert Day1.solve(1, "test_input.txt") == 24_000
  end
end
