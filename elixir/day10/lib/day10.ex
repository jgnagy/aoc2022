defmodule Day10 do
  @moduledoc """
  Documentation for `Day10`.
  """

  @doc """
  Solves Part 1

  ## Examples

      iex> Day10.solve_part1("test_input.txt")
      13140

  """
  def solve_part1(input_file \\ "input.txt") do
    {_, cycles} = input_file
      |> File.read!
      |> String.split("\n", trim: true)
      |> parse_input
      |> Enum.map_reduce([1], &({&1, line_to_cycles(&1, &2)}))

    interesting_signals(cycles)
      |> Enum.reduce(Enum.at(cycles, 19) * 20, &(&1 + &2))
  end

  @doc """
  Solves Part 2

  ## Examples

      iex> Day10.solve_part2("test_input.txt")
      "##..##..##..##..##..##..##..##..##..##..
      ###...###...###...###...###...###...###.
      ####....####....####....####....####....
      #####.....#####.....#####.....#####.....
      ######......######......######......####
      #######.......#######.......#######....."

  """
  def solve_part2(input_file \\ "input.txt") do
    {_, cycles} = input_file
      |> File.read!
      |> String.split("\n", trim: true)
      |> parse_input
      |> Enum.map_reduce([1], &({&1, line_to_cycles(&1, &2)}))

    cycles
      |> Enum.map(&register_to_sprite_locations/1)
      |> Enum.chunk_every(40, 40, :discard)
      |> Enum.map(&draw_pixels_for_chunk/1)
      |> Enum.intersperse("\n")
      |> List.flatten
      |> Enum.join
  end

  defp draw_pixel(sprite_locations, location) do
    if Enum.member?(sprite_locations, location) do
      "#"
    else
      "."
    end
  end

  defp draw_pixels_for_chunk(chunk) do
    Enum.with_index(chunk, &(draw_pixel(&1, &2)))
  end

  defp interesting_signals(cycles) do
    [
      Enum.at(cycles, 59) * 60,
      Enum.at(cycles, 99) * 100,
      Enum.at(cycles, 139) * 140,
      Enum.at(cycles, 179) * 180,
      Enum.at(cycles, 219) * 220
    ]
  end

  defp line_to_cycles(line, cycles)
  defp line_to_cycles(line, cycles) when length(line) == 1 do
    cycles ++ [List.last(cycles)]
  end
  defp line_to_cycles(line, cycles) do
    [_, register_change] = line
    current_value = List.last(cycles)
    cycles ++ [current_value, current_value + String.to_integer(register_change)]
  end

  defp operation_from_line(line), do: String.split(line, " ", trim: true)
  defp parse_input(lines), do: Enum.map(lines, &operation_from_line/1)

  defp register_to_sprite_locations(cycle), do: [cycle - 1, cycle, cycle + 1]
end

Day10.solve_part1 |> IO.puts
Day10.solve_part2 |> IO.puts
