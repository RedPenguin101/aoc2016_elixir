defmodule Aoc2016.Day02 do
  @example "ULL\nRRDDD\nLURDL\nUUUUD" |> String.split("\n")
  @direction %{?U => {0, -1}, ?D => {0, 1}, ?L => {-1, 0}, ?R => {1, 0}}
  @pad {{"x", "x", "1", "x", "x"}, {"x", "2", "3", "4", "x"}, {"5", "6", "7", "8", "8"},
        {"x", "A", "B", "C", "x"}, {"x", "x", "D", "x", "x"}}

  def from_pad({x, y}), do: @pad |> elem(y) |> elem(x)

  def pos_to_num({x, y}), do: 3 * y + x + 1
  def num_to_pos(z), do: {rem(z - 1, 3), div(z - 1, 3)}

  def part1 do
    move_fn = &move_finger_one/2

    Parsing.parse_file("data/day02.txt")
    |> Enum.map(&to_charlist/1)
    |> Enum.scan(5, &do_moves(&1, &2, move_fn))
    |> Enum.join()
  end

  def part2 do
    move_fn = &move_finger_two/2

    Parsing.parse_file("data/day02.txt")
    |> Enum.map(&to_charlist/1)
    |> Enum.scan({0, 2}, &do_moves(&1, &2, move_fn))
    |> Enum.map(&from_pad/1)
    |> Enum.join()
  end

  def do_moves(moves, start, move_fn) do
    Enum.reduce(moves, start, move_fn)
  end

  def move_finger_two(direction, current) do
    new_pos = {x, y} = Complex.add(current, @direction[direction])

    if x >= 0 && x < 5 && y >= 0 && y < 5 && @pad |> elem(y) |> elem(x) != "x" do
      new_pos
    else
      current
    end
  end

  def move_finger_one(direction, current) do
    new_pos = {x, y} = Complex.add(num_to_pos(current), @direction[direction])

    if x >= 0 && x < 3 && y >= 0 && y < 3 do
      pos_to_num(new_pos)
    else
      current
    end
  end
end
