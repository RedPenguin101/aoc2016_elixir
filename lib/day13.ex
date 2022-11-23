defmodule Day13 do
  import Bitwise, only: [&&&: 2]
  import Enum
  import Utils
  import MapSet, only: [union: 2, difference: 2]
  require Integer

  @input 1362
  @example 10

  def part1 do
    p1 = shortest_path({1,1}, {31,39})
    p2 = flood_fill({1,1}, 50) |> MapSet.size
    {p1, p2}
  end

  def flood_fill(start, limit), do: flood_fill( MapSet.new([start]), MapSet.new([start]), limit)
  def flood_fill(v, _, ml) when ml == 0, do: v
  def flood_fill(visited, front_line, moves_left) do
    new_fl = front_line |> flat_map(&connections/1) |> MapSet.new
    new_visited = union(visited, new_fl)
    new_fl_uniq = new_fl |> difference(visited)
    flood_fill(new_visited, new_fl_uniq, moves_left-1)
  end

  def shortest_path(start, target) do
    conn = fn coord -> coord |> connections |> map(&{coord, &1, 1}) end

    dijsktra(start, target, conn)
    |> hd |> second
  end

  def connections({x,y}) do
    [{x+1, y}, {x-1,y}, {x, y+1}, {x, y-1}]
    |> reject(fn {x,y} -> x < 0 || y < 0 || wall?({x,y}) end)
  end

  def wall?({x,y}) do
    :math.pow(x,2) + 3*x + 2*x*y + y + :math.pow(y,2) + @input
    |> round
    |> bit_count
    |> Integer.is_odd
  end

  def bit_count(num), do: bit_count(0, num)
  def bit_count(count, num) when num == 0, do: count
  def bit_count(c, n), do: bit_count(c+1, n &&& (n - 1))

  # Generic Dijkstra
  def add_edge(graph, {start, finish, weight}) do
    graph
    |> MapSet.put({start, finish, weight})
    |> MapSet.put({finish, start, weight})
  end

  def nodes(graph), do: map(graph, &first/1) |> uniq
  def connections(graph, node), do: filter(graph, fn {start, _, _} -> start == node end)

  def priority(queue) do
    {node, {dist, origin}} = min_by(queue, compose(&second/1, &first/1))
    {node, dist, origin}
  end

  def update_queue({from, to, dist}, queue) do
    base_from = Map.get(queue, from)
    base_to = Map.get(queue, to)
    new_dist = (base_from |> first) + dist

    if !base_to || new_dist < (base_to |> first) do
      Map.put(queue, to, {new_dist, from})
    else
      queue
    end
  end

  def dijsktra(start, finish, connect_fn), do: dijsktra([], connect_fn, finish, %{start => {0, start}})
  def dijsktra(done, connect_fn, target, queue) do
    reached? = Map.get(queue, target)
    if reached? do
      {dist, from} = reached?
      [{target, dist, from} | done]
    else
      pri = priority(queue)
      new_done = [pri | done]
      new_queue = connect_fn.(pri |> first)
                  |> reduce(queue, &update_queue/2)
                  |> Map.delete(pri |> first)
                  dijsktra(new_done, connect_fn, target, new_queue)
    end
  end
end
