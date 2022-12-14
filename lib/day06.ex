defmodule Day06 do
  import Enum
  import Utils

  @example "eedadn\ndrvtee\neandsr\nraavrd\natevrs\ntsrnev\nsdttsa\nrasrtv\nnssdts\nntnada\nsvetve\ntesnvt\nvntsnd\nvrdear\ndvrsen\nenarar"

  def part1 do
    get_max = fn m -> Enum.max(Map.to_list(m), fn a, b -> second(a) >= second(b) end) |> first end

    #@example
    File.read!("data/day06.txt")
    |> String.trim
    |> String.split("\n")
    |> map(&String.to_charlist/1)
    |> zip
    |> map(&Tuple.to_list/1)
    |> map(&frequencies/1)
    |> map(get_max)
  end

  def part2 do
    get_min = fn m -> Enum.min(Map.to_list(m), fn a, b -> second(a) < second(b) end) |> elem(0) end

    #@example
    File.read!("data/day06.txt")
    |> String.trim
    |> String.split("\n")
    |> map(&String.to_charlist/1)
    |> zip
    |> map(&Tuple.to_list/1)
    |> map(&frequencies/1)
    |> map(get_min)
  end
end
