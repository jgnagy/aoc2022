defmodule Day18 do
  @moduledoc """
  Solves Advent of Code `Day18`.
  """

  @doc """
  Solves day18 part 1

  ## Examples

      iex> Day18.solve_part1("test_input.txt")
      64

  """
  def solve_part1(input \\ "input.txt") do
    input
      |> File.read!
      |> String.split("\n", trim: true)
      |> parse_input
      |> calculate_surface_area
  end

  @doc """
  Solves day18 part 2

  ## Examples

      iex> Day18.solve_part2("test_input.txt")
      58

  """
  def solve_part2(input \\ "input.txt") do
    input
      |> File.read!
      |> String.split("\n", trim: true)
      |> parse_input
      |> calculate_surface_area(true)
  end

  defp parse_input(lines) do
    lines
      |> Stream.map(&String.split(&1, ","))
      |> Stream.map(
          fn [x, y, z] ->
            {
              String.to_integer(x),
              String.to_integer(y),
              String.to_integer(z)
            }
          end
        )
  end

  defp calculate_surface_area(cubes, exterior_only \\ false)
  defp calculate_surface_area(cubes, exterior_only) when exterior_only == false do
    slices = cubes
      |> Enum.group_by(fn {x, _y, _z} -> x end, fn {_x, y, z} -> {y, z} end)

    # progressively find the exposed surfaces for each slice
    slices
      |> Map.keys
      |> Enum.sort
      |> Enum.map(
          fn x -> calculate_slice_exposed_side_count(x, slices) end
        )
      |> Enum.sum
  end
  defp calculate_surface_area(cubes, _exterior_only) do
    [minx, maxx] = cubes
      |> Enum.min_max_by(fn {x, _y, _z} -> x end)
      |> Tuple.to_list
      |> Enum.map(fn {x, _y, _z} -> x end)

    [miny, maxy] = cubes
      |> Enum.min_max_by(fn {_x, y, _z} -> y end)
      |> Tuple.to_list
      |> Enum.map(fn {_x, y, _z} -> y end)

    [minz, maxz] = cubes
      |> Enum.min_max_by(fn {_x, _y, z} -> z end)
      |> Tuple.to_list
      |> Enum.map(fn {_x, _y, z} -> z end)

    all_possible_cubes = for x <- ((minx - 1)..(maxx + 1)),
                             y <- ((miny - 1)..(maxy + 1)),
                             z <- ((minz - 1)..(maxz + 1)) do
      {x, y, z}
    end

    {_, accessible_faces} = find_accessible_faces(
      {minx - 1, miny - 1, minz - 1}, cubes, all_possible_cubes
    )

    accessible_faces
      |> Map.values
      |> List.flatten
      |> Enum.count
  end

  defp calculate_slice_exposed_side_count(x, slices) do
    pre_squares = slices[x - 1]
    squares = slices[x]

    {_side_counts, full_count} = squares
      |> Enum.flat_map_reduce(
        0,
        fn {y, z}, acc ->
          third_axis_sides = [2]
          exposed_sides = [{y, z - 1}, {y, z + 1}, {y - 1, z}, {y + 1, z}] -- squares
            |> Enum.count
          # See if previous slices contain the same coordinate. If so, remove the touching sides
          side_coverage = if pre_squares, do: Enum.count([{y, z}] -- pre_squares), else: 1
          side_count = [exposed_sides | [((side_coverage - 1) * 2) | third_axis_sides]]
            |> Enum.sum

          {[side_count], acc + side_count}
        end
      )
    full_count
  end

  defp find_accessible_faces(start, obsidian_cubes, all_cubes, accumulator \\ {[], %{}}) do
    start
      |> neighbor_cubes
      |> Enum.reduce(
          accumulator,
          fn cube, acc ->
            {visited_cubes, accessed_faces} = acc
            # recurse through neighbors of neighbors until nowhere to go,
            # skipping obsidian cubes and neighbors not on in all_cubes
            cond do
              # account for faces of obsidian cubes encountered
              Enum.member?(obsidian_cubes, cube) ->
                {
                  [cube | visited_cubes],
                  Map.update(accessed_faces, start, [cube], &([cube | &1]))
                }
              # skip other cubes
              Enum.member?(visited_cubes, cube) -> acc
              Enum.member?(all_cubes, cube) ->
                visited_cubes = [cube | visited_cubes]
                find_accessible_faces(
                  cube, obsidian_cubes, all_cubes, {visited_cubes, accessed_faces}
                )
              true -> acc
            end
          end
        )


  end

  defp neighbor_cubes(cube) do
    {x, y, z} = cube
    [
      {x - 1, y, z}, {x + 1, y, z},
      {x, y - 1, z}, {x, y + 1, z},
      {x, y, z - 1}, {x, y, z + 1}
    ]
  end
end

IO.puts "Part 1: #{Day18.solve_part1("input.txt")}"
IO.puts "Part 2: #{Day18.solve_part2("input.txt")}"
