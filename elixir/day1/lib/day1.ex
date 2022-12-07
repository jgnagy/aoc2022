defmodule Day1 do
  @moduledoc """
  Documentation for Advent of Code 2022 Day1.
  """

  @doc """
  Solve Day1 stuff.

  ## Examples

      iex> Day1.solve(1, "test_input.txt")
      24000

  """
  def solve(how_many \\ 1, input_file \\ "input.txt") do
    File.read!(input_file)
      |> String.split("\n\n", trim: true)
      |> Enum.map(&add_elf_calories/1)
      |> Enum.sort(:desc)
      |> Enum.take(how_many)
      |> Enum.sum
  end

  def solve_part1, do: solve()
  def solve_part2, do: solve(3)

  defp add_elf_calories(entries) do
    String.split(entries)
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum
  end
end

Day1.solve_part1 |> IO.puts
Day1.solve_part2 |> IO.puts
