defmodule Day5 do
  @moduledoc """
  Documentation for `Day5`.

  This one parses the stacks too!
  """

  @doc """
  Solves Part 1

  ## Examples

      iex> Day5.solve_part1("test_input.txt")
      "CMZ"

  """
  def solve_part1(input_file \\ "input.txt", move_multiple \\ false) do
    input_file
      |> File.read!
      |> String.split("\n", trim: true)
      |> parse_input
      |> apply_moves(move_multiple)
      |> then(fn {_, stacks} -> Enum.map(stacks, &(List.first(&1))) end)
      |> Enum.join
  end

  @doc """
  Solves Part 2

  ## Examples

      iex> Day5.solve_part2("test_input.txt")
      "MCD"

  """
  def solve_part2(input_file \\ "input.txt") do
    solve_part1(input_file, true)
  end

  defp apply_moves({stacks, moves}, move_multiple \\ false) do
    moves
      |> Enum.map_reduce(stacks, &({&1, apply_move(&1, &2, move_multiple)}))
  end

  defp apply_move(move, stacks, move_multiple) do
    [count, src, dst] = move
    count = String.to_integer(count)
    src_stack_id = String.to_integer(src) - 1
    dst_stack_id = String.to_integer(dst) - 1

    src_stack = Enum.at(stacks, src_stack_id)
    src_stack_size = Enum.count(src_stack)
    dst_stack = Enum.at(stacks, dst_stack_id)

    # Need to reverse to simulate moving one at a time, unless we're moving multiple
    taken = if move_multiple do
      Enum.take(src_stack, count)
    else
      src_stack
        |> Enum.take(count)
        |> Enum.reverse
    end

    stacks
      |> List.replace_at(src_stack_id, Enum.take(src_stack, count - src_stack_size))
      |> List.replace_at(dst_stack_id, taken ++ dst_stack)
  end

  defp crates_from_line(line) do
    line
      |> String.split("", trim: true)
      |> Enum.chunk_every(3, 4)
      |> Enum.map(&Enum.join/1)
      |> Enum.map(&(String.replace(&1, ~r/[\[\]]/, "")))
  end

  defp move_from_line(line) do
    line
      |> String.split(" ", trim: true)
      |> Enum.filter(&(Regex.match?(~r/^[0-9]+$/, &1)))
  end

  defp parse_input(file_data), do: {parse_stacks(file_data), parse_moves(file_data)}

  defp parse_moves(file_data) do
    file_data
      |> Enum.filter(&(String.starts_with?(&1, "move")))
      |> Enum.map(&move_from_line/1)
  end

  defp parse_stacks(file_data) do
    file_data
      |> Enum.filter(&(String.contains?(&1, "[")))
      |> Enum.map(&crates_from_line/1)
      |> Enum.zip
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(&(Enum.reject(&1, fn s -> String.trim(s) == "" end)))
  end
end

Day5.solve_part1 |> IO.puts
Day5.solve_part2 |> IO.puts
