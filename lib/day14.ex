defmodule Day14 do
  import Enum
  @example "abc"
  @input "yjdafjpo"

  def run do
    part1_hash = 0..1000 |> map(&salted_hash/1)
    #part2_hash = 0..1000 |> map(&re_hash2016/1)

    part1 = find_pad(&salted_hash/1, [], 0, part1_hash) |> hd()
    #part2 = find_pad(&re_hash2016/1, [], 0, part2_hash) |> hd()

    #{part1, part2}
    part1
  end

  def find_pad(_, coll, _, _) when length(coll)==64, do: coll
  def find_pad(hasher, coll, n, thousand_and_one_hashes) do
    case check(n, thousand_and_one_hashes, hasher) do
      {:valid, next_n, next_hashes} -> find_pad(hasher, [n|coll], next_n, next_hashes)
      {:invalid, next_n, next_hashes} -> find_pad(hasher, coll, next_n, next_hashes)
    end
  end

  def check(n, [fst | next_thousand_hashes], hasher) do
    x = first_triple(fst)
    if x && next_thousand_hashes |> any?(&contains_quintuple?(&1, x)) do
      {:valid, n+1, next_thousand_hashes ++ [hasher.(n+1001)]}
    else
      {:invalid, n+1, next_thousand_hashes ++ [hasher.(n+1001)]}
    end
  end

  def contains_quintuple?(string, c), do: String.contains?(string, <<c,c,c,c,c>>)

  def first_triple(string) do
    case string do
      <<a,a,a, _::binary>> -> a
      <<_,_,_>> -> nil
      <<_,rest::binary>>  -> first_triple(rest)
    end
  end

  def salted_hash(n), do: @input <> Integer.to_string(n) |> :erlang.md5 |> Base.encode16(case: :lower)

  def re_hash2016(s), do: re_hash(2016+1, s)
  def re_hash(x, n) when is_number(n), do: re_hash(x, @input <> Integer.to_string(n))
  def re_hash(0, s), do: s
  def re_hash(x, s), do: re_hash(x-1, s |> :erlang.md5 |> Base.encode16(case: :lower))

end
