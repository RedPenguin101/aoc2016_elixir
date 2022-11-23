defmodule Aoc2016.Day04 do
  import Enum
  import Utils

  @example  ["aaaaa-bbb-z-y-x-123[abxyz]",
             "a-b-c-d-e-f-g-h-987[abcde]",
             "not-a-real-room-404[oarel]",
             "totally-real-room-200[decoy]"]
  @re ~r/([a-z-]+)(\d+)\[([a-z]+)\]/

  def get_input, do: Parsing.parse_file("data/day04.txt")

  def parse_room_code(string), do: Regex.run(@re, string) |> tl

  def custom_sort({_n1, f1}, {_n2, f2}) when f1 > f2, do: true
  def custom_sort({_n1, f1}, {_n2, f2}) when f1 < f2, do: false
  def custom_sort({n1, f1}, {n2, f2})   when f1 == f2, do: n1 <= n2

  def real_room?([name, _sector, check]) do
    to_charlist(name)
    |> filter(&(&1 != ?-))
    |> frequencies
    |> sort(&most_common/2)
    |> map(&first/1)
    |> take(5)
    |> Kernel.==(to_charlist(check))
  end

  def shift(letter, _sector) when letter == ?-, do: ?-
  def shift(l, s), do: rem((l+s-97), 26) + 97

  def decode([name, sector, _check]) do
    s = String.to_integer(sector)
    n = name |> to_charlist() |> map(&shift(&1, s)) |> to_string
    {n, s}
  end

  def part1 do
    #@example
    get_input()
    |> map(&parse_room_code/1)
    |> filter(&real_room?/1)
    |> map(&at(&1, 1))
    |> map(&String.to_integer/1)
    |> sum
  end

  def part2 do
    get_input()
    |> map(&parse_room_code/1)
    |> filter(&real_room?/1)
    |> map(&decode/1)
    |> filter(&(&1 |> first |> String.starts_with?("northpole")))
    |> hd
    |> second
  end
end
