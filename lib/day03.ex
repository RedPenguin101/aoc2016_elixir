defmodule Aoc2016.Day03 do
  def input do
    Parsing.parse_file("data/day03.txt", &Parsing.row_parse_integers/1)
    |> Enum.map(&List.to_tuple/1)
  end

  def part1 do
    input()
    |> Enum.filter(&valid_triangle?/1)
    |> length
  end

  def part2 do
    input()
    |> reshape
    |> Enum.filter(&valid_triangle?/1)
    |> length
  end

  def reshape(numbers) when length(numbers) == 0, do: []
  def reshape([a,b,c | rest]), do: List.zip([a,b,c]) ++ reshape(rest)

  def valid_triangle?({a,b,c}), do: a+b>c && a+c>b && b+c>a
end
