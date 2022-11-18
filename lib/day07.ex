defmodule Day07 do
  import Enum
  @examples ["abba[mnop]qrst","abcd[bddb]xyyx","aaaa[qwer]tyui","ioxxoj[asdfgh]zxcvbn"]
  @examples2 ["aba[bab]xyz","xyx[xyx]xyx","aaa[kek]eke","zazbz[bzb]cdb"]

  def unterleave(list, n) do
    for i <- 0..n-1 do
      take_every(drop(list, i), n)
    end
  end

  def part1 do
    @examples
    File.read!("data/day07.txt") |> String.trim |> String.split("\n")
    |> map(&check_tls/1)
    |> filter(&Function.identity/1)
    |> length
  end

  def check_tls(string) do
    valid_tls = fn bools ->
      [supernet, hypernet] = unterleave(bools, 2)
      any?(supernet) && !any?(hypernet)
    end

    string
    |> String.split(["[", "]"])
    |> map(&to_charlist/1)
    |> map(&has_abba_pattern?/1)
    |> valid_tls.()
  end

  def has_abba_pattern?(charlist) when length(charlist) < 4, do: false
  def has_abba_pattern?(charlist) do
    case charlist do
      [a,a,a,a | _] -> has_abba_pattern?(tl(charlist))
      [a,b,b,a | _] -> true
      _         -> has_abba_pattern?(tl(charlist))
    end
  end

  def part2 do
    @examples2
    File.read!("data/day07.txt") |> String.trim |> String.split("\n")
    |> map(&check_ssl/1)
    |> filter(&Function.identity/1)
    |> length
  end

  def check_ssl(string) do
    flip = fn <<a,b,a>> -> <<b,a,b>> end

    [supernet, hypernet] = string
                           |> String.split(["[", "]"])
                           |> map(&to_charlist/1)
                           |> map(&aba_patterns/1)
                           |> unterleave(2)
                           |> map(&concat/1)

    not MapSet.disjoint?(MapSet.new(supernet), MapSet.new(map(hypernet, flip)))
  end

  def aba_patterns(charlist), do: aba_patterns([], charlist)
  def aba_patterns(acc, charlist) when length(charlist) < 3, do: acc
  def aba_patterns(acc, charlist) do
    case charlist do
      [a,a,a | _ ] -> aba_patterns(acc, tl(charlist))
      [a,b,a | _ ] -> aba_patterns([<<a,b,a>> | acc], tl(charlist))
      _            -> aba_patterns(acc, tl(charlist))
    end
  end
end
