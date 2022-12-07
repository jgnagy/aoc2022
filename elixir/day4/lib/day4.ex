defmodule Day4 do
  @moduledoc """
  Documentation for `Day4`.
  """

  @doc """
  Solves Part 1

  ## Examples

      iex> Day4.solve_part1("test_input.txt")
      2

  """
  def solve_part1(input_file \\ "input.txt") do
    File.read!(input_file)
      |> String.split("\n", trim: true)
      |> Enum.map(&ranges_from_line/1)
      |> Enum.map(&Enum.to_list/1)
      |> Enum.filter(fn [first, last] -> subrange?(first, last) || subrange?(last, first) end)
      |> length
  end

  @doc """
  Solves Part 2

  ## Examples

      iex> Day4.solve_part2("test_input.txt")
      4

  """
  def solve_part2(input_file \\ "input.txt") do
    File.read!(input_file)
      |> String.split("\n", trim: true)
      |> Enum.map(&ranges_from_line/1)
      |> Enum.filter(fn [first, last] -> !Range.disjoint?(first, last) end)
      |> length
  end

  defp range_from_elf(elf) do
    elf
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)
      |> then(fn [x, y] -> x..y end)
  end

  defp ranges_from_line(line) do
    line
      |> String.split(",", trim: true)
      |> Enum.map(&range_from_elf/1)
  end

  defp subrange?(range, other) do
    Enum.to_list(range) -- Enum.to_list(other)
      |> Enum.empty?()
  end
end

Day4.solve_part1() |> IO.puts()
Day4.solve_part2() |> IO.puts()
