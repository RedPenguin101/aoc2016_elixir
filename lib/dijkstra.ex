defmodule Dijkstra do
  import Utils
  import Enum

  # General graph stuff
  # adding _bidirectional_ edge
  def add_edge(graph, {start, finish, weight}) do
    graph
    |> MapSet.put({start, finish, weight})
    |> MapSet.put({finish, start, weight})
  end

  def nodes(graph), do: map(graph, &first/1) |> uniq
  def connections(graph, node), do: filter(graph, fn {start, _, _} -> start == node end)

  # Priority Queue stuff
  # queue is a map of:
  #       entry => {priority, origin}
  # e.g %{:s    => {0, :s}}
  # priority is the thing with the shortest distance
  # return a 3tuple
  def priority(queue) do
    {node, {dist, origin}} = min_by(queue, compose(&second/1, &first/1))
    {node, dist, origin}
  end

  # Updating the queue is passed an edge
  # updating looks up the to and from nodes in the queue
  # if the to-node isn't in the queue, just put it in the queue
  # if the to-node is already there, and the existing distance to
  # reach that nde is greater than the 'new' one, then put the new distance
  # in the queue, along with the new origin.
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

  def dijsktra(graph, start, finish), do: dijsktra([], graph, finish, %{start => {0, start}})
  # Done is list of {node, dist, from}
  # the shortest path is the distance (second element) of the first entry
  # in done
  def dijsktra(done, graph, target, queue) do
    reached? = Map.get(queue, target)
    if reached? do
      {dist, from} = reached?
      [{target, dist, from} | done]
    else
      pri = priority(queue)
      new_done = [pri | done]
      new_queue = graph
                  |> connections(pri |> first)
                  |> reduce(queue, &update_queue/2)
                  |> Map.delete(pri |> first)
      dijsktra(new_done, graph, target, new_queue)
    end
  end


  def dijsktra_dynamic(start, finish, connect_fn), do: dijsktra_dynamic([], connect_fn, finish, %{start => {0, start}})
  def dijsktra_dynamic(done, connect_fn, target, queue) do
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
                  dijsktra_dynamic(new_done, connect_fn, target, new_queue)
    end
  end

  # dijkstra returns all the nodes visited before you hit the target,
  # so some won't be on the shortest path. You need to 'walk' the result
  # to find the path
  def find_path([]), do: []
  def find_path([{to, dist, from} | rst]) do
    unconnected = fn {x,_,_} -> x != from end
    [{to, dist} | rst |> drop_while(unconnected) |> find_path]
  end

  def demo do
    MapSet.new
    |> add_edge({:s, :a, 7})
    |> add_edge({:s, :b, 2})
    |> add_edge({:s, :c, 3})
    |> add_edge({:a, :d, 4})
    |> add_edge({:a, :b, 3})
    |> add_edge({:b, :d, 4})
    |> add_edge({:b, :h, 1})
    |> add_edge({:c, :l, 2})
    |> add_edge({:d, :f, 5})
    |> add_edge({:e, :g, 2})
    |> add_edge({:e, :k, 5})
    |> add_edge({:f, :h, 3})
    |> add_edge({:g, :h, 2})
    |> add_edge({:i, :l, 4})
    |> add_edge({:i, :j, 6})
    |> add_edge({:i, :k, 4})
    |> add_edge({:j, :l, 4})
    |> add_edge({:j, :j, 4})
    |> dijsktra(:s, :e)
    |> find_path()
    # => [e: 7, g: 5, h: 3, b: 2, s: 0]
  end
end
