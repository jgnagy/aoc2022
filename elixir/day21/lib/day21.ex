defmodule Day21 do
  @moduledoc """
  Solutions for Advent of Code `Day21`.
  """

  @doc """
  Solves part 1 of Day 21

  ## Examples

      iex> Day21.solve_part1("test_input.txt")
      152

  """
  def solve_part1(input \\ "input.txt") do
    input
      |> File.read!
      |> String.split("\n", trim: true)
      |> parse_input
      |> perform_operation("root", "root")
  end

  @doc """
  Solves part 2 of Day 21

  ## Examples

      iex> Day21.solve_part2("test_input.txt")
      301

  """
  def solve_part2(input \\ "input.txt") do
    input
      |> File.read!
      |> String.split("\n", trim: true)
      |> parse_input
      |> apply_translation_fix
  end

  defp parse_input(lines) do
    lines
      |> Stream.map(&String.split(&1, ": "))
      |> Enum.map(fn [name, op_line] -> {name, op_line} end)
      |> Map.new
  end

  defp perform_operation(operations, op_line, target \\ "root")
  defp perform_operation(operations, op_line, target) when op_line == target do
    perform_operation(operations, operations["root"], target)
  end
  defp perform_operation(operations, op_line, target) do
    cond do
      Regex.match?(~r/^[0-9]+$/, op_line) ->
        String.to_integer(op_line)
      op_line == "humn" ->
        "humn"
      true ->
        [p1, op, p2] = String.split(op_line, " ")
        resolved_p1 = perform_operation(operations, operations[p1], target)
        resolved_p2 = perform_operation(operations, operations[p2], target)
        if resolved_p1 == "humn" || resolved_p2 == "humn" do
          "humn"
        else
          case op do
            "+" -> resolved_p1 + resolved_p2
            "-" -> resolved_p1 - resolved_p2
            "*" -> resolved_p1 * resolved_p2
            "/" -> resolved_p1 / resolved_p2 |> trunc
          end
        end
    end
  end

  defp apply_translation_fix(operations) do
    translated_operations = operations
      |> Map.update!("humn", fn _ -> "humn" end)

    [root1, _, root2] = operations["root"]
      |> String.split(" ")

    rootv1 = perform_operation(translated_operations, operations[root1])
    rootv2 = perform_operation(translated_operations, operations[root2])

    root = if rootv1 == "humn", do: rootv2, else: rootv1
    humn_path = if rootv1 == "humn", do: root1, else: root2

    walk_child_path(translated_operations, humn_path, root)
  end

  defp walk_child_path(_operations, key, expected_value) when key == "humn" do
    expected_value
  end
  defp walk_child_path(operations, key, expected_value) do
    [key1, op, key2] = operations[key]
      |> String.split(" ")

    keyv1 = perform_operation(operations, operations[key1])
    keyv2 = perform_operation(operations, operations[key2])

    humn_path = if keyv1 == "humn", do: key1, else: key2

    value = if keyv1 == "humn" do
      case op do
        "+" -> expected_value - keyv2
        "-" -> expected_value + keyv2
        "*" -> expected_value / keyv2 |> trunc
        "/" -> expected_value * keyv2
      end
    else
      case op do
        "+" -> expected_value - keyv1
        "-" -> keyv1 - expected_value
        "*" -> expected_value / keyv1 |> trunc
        "/" -> keyv1 / expected_value |> trunc
      end
    end

    walk_child_path(operations, humn_path, value)
  end
end

Day21.solve_part1 |> IO.puts
Day21.solve_part2 |> IO.puts
