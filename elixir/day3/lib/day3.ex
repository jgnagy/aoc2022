defmodule Day3 do
  @moduledoc """
  Solution for AoC 2022 `Day3`.
  """

  @letters Enum.concat([?a..?z, ?A..?Z]) |> Enum.map(fn x -> <<x :: utf8>> end)

  @doc """
  Solves Part 1

  ## Examples

      iex> Day3.solve_part1("test_input.txt")
      157

  """
  def solve_part1(input_file \\ "input.txt") do
    File.read!(input_file)
      |> String.split("\n", trim: true)
      |> Enum.map(&points_from_rucksacks_line/1)
      |> Enum.sum()
  end

  @doc """
  Solves Part 2

  ## Examples

      iex> Day3.solve_part2("test_input.txt")
      70

  """
  def solve_part2(input_file \\ "input.txt") do
    File.read!(input_file)
      |> String.split("\n", trim: true)
      |> Enum.chunk_every(3)
      |> Enum.map(&points_from_badge_lines/1)
      |> Enum.sum()
  end

  defp intersection(rucksack_list) do
    [head | tail] = rucksack_list
    tail
      |> Enum.reduce(head, fn x, acc -> Enum.filter(x, &Enum.member?(acc, &1)) end)
      |> Enum.uniq()
  end

  defp points_for_letters(letters) do
    {_, points} = letters
      |> Enum.map_reduce(0, fn l, acc -> {l, acc + Enum.find_index(@letters, &(l == &1)) + 1 } end)

    points
  end

  defp points_from_badge_lines(lines) do
    lines
      |> Enum.map(&(String.split(&1, "", trim: true)))
      |> intersection()
      |> points_for_letters()
  end

  defp points_from_rucksacks_line(line) do
    line
      |> rucksacks_from_line()
      |> intersection()
      |> points_for_letters()
  end

  defp rucksacks_from_line(line) do
    line
      |> String.split_at(split_position(line))
      |> Tuple.to_list()
      |> Enum.map(&(String.split(&1, "", trim: true)))
      |> Enum.uniq()
  end

  defp split_position(line), do: round(String.length(line) / 2)
end

Day3.solve_part1() |> IO.puts()
Day3.solve_part2() |> IO.puts()
