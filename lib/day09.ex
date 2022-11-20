defmodule Day09 do
  import Enum

  def part1 do
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
    [l, chars, reps] = Regex.run(~r/(\d+)x(\d+)/, rst)

    s_len    = String.length(l)+1
    full_len = String.length(rst)
    reps     = String.to_integer(reps)
    chars_to_take = String.to_integer(chars)

    reps *
      decomp_count(String.slice(rst, s_len, chars_to_take)) +
      decomp_count(String.slice(rst, s_len+chars_to_take..full_len))
  end

  def decomp_count(string) do
    s_len    = ~r/[A-Z]+/ |> Regex.run(string) |> hd |> String.length
    full_len = String.length(string)

    s_len + decomp_count(String.slice(string, s_len..full_len))
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
