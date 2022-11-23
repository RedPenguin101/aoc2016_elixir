defmodule Utils do
  import Enum

  # tuple convenience
  def first(tuple),  do: elem(tuple, 0)
  def second(tuple), do: elem(tuple, 1)
  def last(tuple),   do: elem(tuple, tuple_size(tuple)-1)

  # sets
  def set(xs),       do: MapSet.new(xs)

  # Function composition

  def compose(f, g), do: fn a -> g.(f.(a)) end
  def juxt(f, g), do: fn a -> {f.(a), g.(a)} end

  @doc "Unterleave is the reversal of interleaving. given a list of [a1,b1,c1,a2,b2,c2,...] and
  an n of 3, it will produce a list of lists [[a1, a2, a3 ...], [b1, b2, b3 ...], [c1, c2, c3]]"
  def unterleave(list, n) do
    for i <- 0..n-1 do
      Enum.take_every(Enum.drop(list, i), n)
    end
  end

  @doc "A descending ('most common') sorter for frequency maps, or lists of {x=>freq} tuples.
  Sorts by the frequency first, and by the value in case of a tiebreak."
  def most_common({_n1, f1}, {_n2, f2}) when f1 > f2, do: true
  def most_common({_n1, f1}, {_n2, f2}) when f1 < f2, do: false
  def most_common({n1, f1}, {n2, f2})   when f1 == f2, do: n1 <= n2

  # Coordinates etc

  @doc "Given a set of coordinates {x>0,y>0}, will draw them on the screen"
  def draw(coords) do
    {_xmin, xmax} = coords |> map(&first/1) |> min_max
    {_ymin, ymax} = coords |> map(&second/1) |> min_max

    for y<-0..ymax do
      for x<-0..xmax do
        if MapSet.member?(coords, {x,y}), do: "#", else: " "
      end
    end

    |> map(&join/1)
    |> join("\n")
    |> IO.puts
  end
end
