defmodule Aoc2016 do
  def run do
    IO.puts("Day 1 Part 1: " <> Integer.to_string(Aoc2016.Day1.part1))
    IO.puts("Day 1 Part 2: " <> Integer.to_string(Aoc2016.Day1.part2))

    IO.puts("Day 2 Part 1: " <> Aoc2016.Day02.part1)
    IO.puts("Day 2 Part 2: " <> Aoc2016.Day02.part2)

    IO.puts("Day 3 Part 1: " <> Integer.to_string(Aoc2016.Day03.part1))
    IO.puts("Day 3 Part 2: " <> Integer.to_string(Aoc2016.Day03.part2))

    IO.puts("Day 4 Part 1: " <> Integer.to_string(Aoc2016.Day04.part1))
    IO.puts("Day 4 Part 2: " <> Integer.to_string(Aoc2016.Day04.part2))

    IO.puts("Day 5 Part 1: " <> Aoc2016.Day05.part1)
    IO.puts("Day 5 Part 2: " <> Aoc2016.Day05.part2)
  end

end

Aoc2016.run
