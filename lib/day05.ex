defmodule Aoc2016.Day05 do
  import Enum
  @input "ugkcyxxp" # door id
  @example "abc"

  def part1 do
    @input
    #@example
    |> find_password_part1
    |> map(&Integer.to_charlist(&1, 16))
    |> join
    |> String.downcase
  end

  def part2 do
    @input
    #@example
    |> find_password_part2
    |> sort
    |> map(&elem(&1, 1))
    |> map(&Integer.to_charlist(&1, 16))
    |> join
    |> String.downcase
  end

  def find_password_part1(input), do: find_password_part1(input, [], 0)
  def find_password_part1(_, found, _) when length(found) == 8, do: found |> reverse
  def find_password_part1(input, found, num) do
    case good_hash?(:erlang.md5(input <> Integer.to_string(num))) do
      {:no}        -> find_password_part1(input, found, num+1)
      {:ok1, c}    -> find_password_part1(input, [c | found], num+1)
      {:ok2, c, _} -> find_password_part1(input, [c | found], num+1)
    end
  end

  def find_password_part2(input), do: find_password_part2(input, Map.new(), 0)
  def find_password_part2(_, found, _) when map_size(found) == 8, do: found
  def find_password_part2(input, found, num) do
    case good_hash?(:erlang.md5(input <> Integer.to_string(num))) do
      {:no}        -> find_password_part2(input, found, num+1)
      {:ok1, _}    -> find_password_part2(input, found, num+1)
      {:ok2, c, d} -> find_password_part2(input, Map.put_new(found, c, d), num+1)
    end
  end

  def good_hash?(binary) do
    <<a,b,c,d,_::binary>> = binary
    cond do
      a>0 || b>0 -> {:no}
      c < 8      -> {:ok2, c, Bitwise.>>>(d,4)}
      c <= 0xF   -> {:ok1, c}
      c > 0xF    -> {:no}
    end
  end
end
