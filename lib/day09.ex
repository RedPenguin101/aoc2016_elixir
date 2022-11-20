defmodule Day09 do
  import Enum

  @examples ["ADVENT", "A(1x5)BC", "(3x3)XYZ", "A(2x2)BCD(2x2)EFG",
             "(6x1)(1x3)A", "X(8x2)(3x3)ABCY"]
  @examples_out ["ADVENT", "ABBBBBC", "XYZXYZXYZ", "ABCBCDEFEFG",
                 "(1x3)A", "X(3x3)ABC(3x3)ABCY"]


  def part1 do
    @examples
    |> map(&to_charlist/1)
    |> map(&decompress/1)
    |> map(&to_string/1)
    |> Kernel.==(@examples_out)

    File.read!("data/day09.txt")
    |> String.trim
    |> to_charlist
    |> decompress
    |> count
  end

  def part2 do
    File.read!("data/day09.txt")
    |> String.trim
    |> decomp_count
  end

  def decomp_count(""), do: 0

  def decomp_count("(" <> rst) do
    alias String, as: S

    re = ~r/(\d+)x(\d+)/
    [l, chars, reps] = Regex.run(re, rst)
    reps  = S.to_integer(reps)
    chars = S.to_integer(chars)
    len   = S.length(l)+1
    reps *
      decomp_count(S.slice(rst, len, chars)) +
      decomp_count(S.slice(rst, len+chars..S.length(rst)))
  end

  def decomp_count(string) do
    alias String, as: S

    s = Regex.run(~r/[A-Z]+/, string) |> hd |> S.length
    s + decomp_count(S.slice(string, s..S.length(string)))
  end

  def decompress(charlist), do: decompress([], charlist)
  def decompress(out, in_char) when length(in_char) < 5, do: out ++ in_char
  def decompress(out, in_char) do
    not_closing_bracket = &(&1 != ?))

    get_ints = fn charlist ->
      s = charlist |> take_while(not_closing_bracket) |> to_string
      Regex.run(~r/(\d+)x(\d+)/, s)
      |> tl
      |> map(&String.to_integer/1)
    end

    case in_char do
      [?( | rest] ->
        [a, b] = get_ints.(rest)
        r = rest |> drop_while(not_closing_bracket) |> tl
        decompress(out ++ (r |> take(a) |> repeat(b)), drop(r, a))

      [first | rest] -> out ++ [first] |> decompress(rest)
    end
  end

  def repeat(_, n) when n==0, do: []
  def repeat(charlist, n) do
    charlist ++ repeat(charlist, n-1)
  end
end
