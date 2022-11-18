defmodule Aoc2016.Day1 do
  def part1 do
    Parsing.parse_file("data/day01.txt", &Parsing.row_parse_comma_sep/1)
    |> hd
    |> Enum.reduce({{0,1},{0,0}}, &process/2)
    |> elem(1)
    |> Complex.abs
  end

  def part2 do
    Parsing.parse_file("data/day01.txt", &Parsing.row_parse_comma_sep/1)
    |> hd
    |> find_repeat(MapSet.new([]), {{0,1},{0,0}})
    |> Complex.abs
  end

  defp find_repeat(move_list, visited, state) do
    [move | rst] = move_list
    {heading, new_pos, path} = process(move, state)
    repeats = Enum.filter(path, &MapSet.member?(visited, &1))

    if not Enum.empty?(repeats) do
      hd(repeats)
    else
      new_visited = MapSet.union(visited, MapSet.new(path))
      find_repeat(rst, new_visited, {heading, new_pos})
    end
  end

  defp process(move, state) do
    heading = elem(state,0)
    pos = elem(state,1)
    {turn, amount} = parse_movement(move)
    new_heading = Complex.mult(heading, turn)
    new_pos = Complex.add(pos, Complex.smult(new_heading, amount))

    visited = 1..amount
              |> Enum.map(&Complex.smult(new_heading, &1))
              |> Enum.map(&Complex.add(pos, &1))

    {new_heading, new_pos, visited}
  end

  defp parse_movement(movement) do
    case String.split_at(movement, 1) do
      {"R", amount} -> {{0,-1}, String.to_integer(amount)}
      {"L", amount} -> {{0, 1}, String.to_integer(amount)}
    end
  end
end
