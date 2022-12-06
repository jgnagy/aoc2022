defmodule Day2 do
  # in the form of [move, winning_counter]
  @winning_matches [["rock", "paper"], ["paper", "scissors"], ["scissors", "rock"]]
  @translations %{"rock" => ["A", "X"], "paper" => ["B", "Y"], "scissors" => ["C", "Z"]}

  @moduledoc """
  Documentation for Advent of Code 2022 Day2.
  """

  @doc """
  Solve for Day2 part 1.

  ## Examples

      iex> Day2.solve_part1("test_input.txt")
      15

  """
  def solve_part1(input_file \\ "input.txt") do
    plays(input_file)
      |> Enum.map(&p1_game_to_moves/1)
      |> Enum.map(&score_game/1)
      |> Enum.sum
  end

  @doc """
  Solve for Day2 part 2.

  ## Examples

      iex> Day2.solve_part2("test_input.txt")
      12

  """
  def solve_part2(input_file \\ "input.txt") do
    plays(input_file)
      |> Enum.map(&p2_game_to_moves/1)
      |> Enum.map(&score_game/1)
      |> Enum.sum
  end

  defp allowed_moves, do: Enum.map(@winning_matches, &(List.first(&1)))

  defp plays(input_file), do: File.read!(input_file) |> String.split("\n", trim: true)

  defp p1_game_to_moves(game), do: String.split(game) |> Enum.map(&translate_move/1)

  defp p2_game_to_moves(game) do
    case String.split(game) do
      [theirs, "X"] -> find_losing_game_for(theirs)
      [theirs, "Y"] -> [translate_move(theirs), translate_move(theirs)]
      [theirs, "Z"] -> find_winning_game_for(theirs)
    end
  end

  defp score_game(moves), do: score_my_move(moves) + score_match(moves)

  defp score_my_move(moves) do
    Enum.find_index(allowed_moves(), &(&1 == List.last(moves))) + 1
  end

  defp score_match(moves) do
    cond do
      Enum.member?(@winning_matches, moves) -> 6
      Enum.uniq(moves) |> Enum.count() == 1 -> 3
      true -> 0
    end
  end

  defp translate_move(move) do
    {key, _} = Enum.find(@translations, nil, fn {_, values} -> Enum.member?(values, move) end)
    key
  end

  defp find_losing_game_for(move) do
    Enum.find(@winning_matches, nil, fn [_x, y] -> y == translate_move(move) end)
      |> Enum.reverse()
  end

  defp find_winning_game_for(move) do
    Enum.find(@winning_matches, nil, fn [x, _y] -> x == translate_move(move) end)
  end
end

Day2.solve_part1() |> IO.puts
Day2.solve_part2() |> IO.puts
