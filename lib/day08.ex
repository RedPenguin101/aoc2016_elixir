defmodule Day08 do
  import Enum

  @example ["rect 3x2","rotate column x=1 by 1", "rotate row y=0 by 4", "rotate column x=1 by 1"]
  @re ~r/(\d+)[a-z| ]+(\d+)/
  #@rows 3 #example
  @rows 6
  #@cols 7 #example
  @cols 50

  def update_tuple(tuple, idx, fun) do
    current = elem(tuple, idx)
    put_elem(tuple, idx, fun.(current))
  end

  def part1 do
    @example
    File.read!("data/day08.txt")
    |> String.trim
    |> String.split("\n")
    |> map(&parse_row/1)
    |> reduce(%{}, &proc_instr/2)
    |> count
  end

  def part2 do
    @example
    File.read!("data/day08.txt")
    |> String.trim
    |> String.split("\n")
    |> map(&parse_row/1)
    |> reduce(%{}, &proc_instr/2)
    |> draw
  end

  def proc_instr({:rect, {cols,rows}}, screen), do: rect(screen, cols, rows)
  def proc_instr({row_or_col, {num,amount}}, screen), do: rotate(screen, row_or_col, num, amount)

  def rect(screen, cols, rows) do
    coords = for x <- 0..cols-1, y <-0..rows-1 do
      {x, y}
    end

    reduce(coords, screen, fn coord, scrn -> Map.put(scrn, coord, 1) end)
  end

  def rotate(screen, row_or_col, num, amount) do
    {f, m, wrap} = case row_or_col do
                           :col -> {0, 1, @rows}
                           :row -> {1, 0, @cols}
                         end

    push = fn a -> rem(a+amount, wrap) end

    change = Map.filter(screen, fn {c, _} -> elem(c,f) == num end)
    change
    |> map(fn {c, v} -> {update_tuple(c, m, push), v} end)
    |> Map.new
    |> Map.merge(Map.drop(screen, Map.keys(change)))
  end

  def draw(screen) do
    for y<-0..@rows-1 do
      for x<-0..@cols-1 do
        if screen[{x,y}], do: "X", else: " "
      end
    end
    |> map(&join/1)
    |> join("\n")
    |> IO.puts
  end

  def parse_row(string) do
    case string do
      "rect " <> rest -> {:rect, get_integers(rest)}
      "rotate column x=" <> rest -> {:col, get_integers(rest)}
      "rotate row y=" <> rest -> {:row, get_integers(rest)}
    end
  end

  def get_integers(string) do
    Regex.run(@re, string)
    |> tl
    |> map(&String.to_integer/1)
    |> List.to_tuple
  end
end
