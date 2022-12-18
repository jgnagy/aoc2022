defmodule Day16 do
  @moduledoc """
  Solves for `Day16`.
  """

  @parser ~r/^Valve (?<label>[A-Z]{2}) has flow rate=(?<rate>[0-9]+); tu.+es? (?<conns>.+)$/

  @doc """
  Solves Advent of Code day 16 part 1.

  ## Examples

      iex> Day16.solve_part1(File.read!("test_input.txt"))
      1651

  """
  def solve_part1(data) do
    data
      |> String.split("\n", trim: true)
      |> parse_input
      |> build_graph
      |> pressure_by_path(30, 30, 0, fn _next, v, p -> p + v end)
      |> Enum.max
  end

  @doc """
  Solves Advent of Code day 16 part 2

  ## Examples

      iex> Day16.solve_part2(File.read!("test_input.txt"))
      1707

  """
  def solve_part2(data) do
    data
      |> String.split("\n", trim: true)
      |> parse_input
      |> build_graph
      |> find_best_path_pair_pressure
  end

  defp find_best_path_pair_pressure(graph) do
    {_path_pair, pressure} = find_best_path_pair(graph)
    pressure
  end

  defp find_best_path_pair(graph, total_runtime \\ 26, attempts \\ 26, multi \\ false)
  defp find_best_path_pair(_graph, _total_runtime, attempts, _multi) when attempts <= 1, do: {[], 0}
  defp find_best_path_pair(graph, total_runtime, attempts, multi) do
    solutions = graph
      |> pressure_by_path(
          total_runtime,
          attempts,
          {[], 0},
          fn next, vent, {path, prev} ->
            {[next | path], prev + vent}
          end
        )
      |> Enum.map(fn {path, released} -> {MapSet.new(path), released} end)
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
      |> Enum.map(fn {s, lst} -> {s, Enum.max(lst)} end)
      |> each_pair
      |> find_and_combine_disjoin_path_pair

    cond do
      Enum.empty?(solutions) && !multi ->
        # This means it is impossible to _not_ overlap in the given time for two independent walkers
        # We'll need to try *a lot* more smaller options where we wait at valves for an ideal pairing

        # First we need to max distance from :AA to any valve
        low = max_distance_between_points(graph)

        (low..(attempts - 1))
          |> Enum.reduce(
              [],
              fn attempt, acc ->
                [find_best_path_pair(graph, total_runtime, attempt, true) | acc]
              end
            )
          |> Enum.max_by(fn {_pair, pressure} -> pressure end, fn -> {[], 0} end)
      Enum.empty?(solutions) ->
        {[], 0}
      true ->
        solutions |> Enum.max_by(fn {_pair, pressure} -> pressure end)
    end
  end

  defp find_and_combine_disjoin_path_pair(list) do
    list
      |> Stream.filter(
          fn {{h_path, _}, {el_path, _}} ->
            MapSet.disjoint?(h_path, el_path)
          end
        )
      |> Stream.map(
          fn {{h_path, h}, {el_path, e}} ->
            {[{h_path, h}, {el_path, e}], h + e}
          end
        )
  end

  defp pressure_by_path(graph, total_runtime, attempts, init, fun) do
    Map.merge(calculate_rates(graph), calculate_distances(graph))
      |> pressure_by_path(:AA, {total_runtime, attempts}, attempts, valves_with_positive_rate(graph), init, fun)
  end

  defp pressure_by_path(_, _, _, _, [], res, _), do: [res]
  defp pressure_by_path(storage, cur, runtime_info, rem_time, rem_nodes, res, fun) do
    Enum.flat_map(
      rem_nodes,
      fn next ->
        dist = storage[{cur, next}]
        {total_runtime, path_max_runtime} = runtime_info

        cond do
          # here, we're attempting shorter paths to optimize when to move or wait
          dist + 1 > rem_time && total_runtime > path_max_runtime ->
            {path, pressure} = res
            vent = path
              |> Enum.map(&(storage[&1]))
              |> Enum.sum

            vent = vent * ((total_runtime - path_max_runtime) + rem_time - dist)
            [{path, pressure + vent}]
          # this will happen when there are more valves than we can visit
          rem_time - dist - 1 > 0 ->
            rem_time = rem_time - dist - 1
            vent = storage[next] * rem_time
            res = fun.(next, vent, res)
            pressure_by_path(
              storage, next, runtime_info, rem_time, List.delete(rem_nodes, next), res, fun
            )
          true ->
            [res]
        end
      end
    )
  end

  defp valve_data_from_line(line) do
    %{"rate" => r, "label" => l, "conns" => c } = Regex.named_captures(@parser, line)
    %{
      "rate" => String.to_integer(r),
      "label" => String.to_atom(l),
      "conns" => String.split(c, ", ") |> Enum.map(&String.to_atom/1)
    }
  end

  defp parse_input(lines), do: Enum.map(lines, &valve_data_from_line/1)

  defp build_graph(valves) do
    valves
      |> Enum.reduce(
        Graph.new(type: :directed, vertex_identifier: &(&1)),
        fn v, graph ->
          graph
            |> Graph.add_edges(conns_to_edges(v["conns"], v["label"]))
            |> Graph.label_vertex(v["label"], label: v["label"], rate: v["rate"])
        end
      )
  end

  defp valves_with_positive_rate(graph) do
    graph
      |> Graph.vertices
      |> Enum.filter(&(Graph.vertex_labels(graph, &1)[:rate] > 0))
  end

  defp calculate_distances(graph) do
    graph
      |> valves_with_positive_rate
      |> Enum.concat([:AA])
      |> each_pair
      |> Enum.reduce(
        %{},
        fn {src, dst}, map ->
          weight = graph
            |> Graph.dijkstra(src, dst)
            |> tl
            |> Enum.count
          Map.put(map, {src, dst}, weight)
        end
      )
  end

  defp max_distance_between_points(graph) do
    graph
      |> calculate_distances
      |> Map.values
      |> Enum.max
  end

  defp calculate_rates(graph) do
    graph
      |> valves_with_positive_rate
      |> Map.new(&{&1, Graph.vertex_labels(graph, &1)[:rate]})
  end

  defp conns_to_edges(list, label), do: Enum.map(list, &{label, &1})
  defp each_pair(list), do: for(s <- list, d <- list, s != d, do: {s, d})
end

File.read!("input.txt")
  |> Day16.solve_part1
  |> IO.puts

File.read!("input.txt")
  |> Day16.solve_part2
  |> IO.puts
