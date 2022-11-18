defmodule Day08 do
  import Enum

  @example ["rect 3x2","rotate column x=1 by 1", "rotate row y=0 by 4", "rotate column x=1 by 1"]
  @re ~r/(\d+)[a-z| ]+(\d+)/
  #@rows 3 #example
  @rows 6
  #@cols 7 #example
  @cols 50

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
  def proc_instr({:row, {row,amount}}, screen), do: row(screen, row, amount)
  def proc_instr({:col, {col,amount}}, screen), do: col(screen, col, amount)

  def rect(screen, cols, rows) do
    coords = for x <- 0..cols-1, y <-0..rows-1 do
      {x, y}
    end

    reduce(coords, screen, fn coord, scrn -> Map.put(scrn, coord, 1) end)
  end

  def row(screen, row_num, amount) do
    row = Map.filter(screen, fn {{_x, y}, _} -> y == row_num end)
    others = Map.filter(screen, fn {{_x, y}, _} -> y != row_num end)

    map(row, fn {{x, y}, v} -> {{rem(x+amount, @cols), y}, v} end) |> Map.new
    |> Map.merge(others)
  end

  def col(screen, col_num, amount) do
    col = Map.filter(screen, fn {{x, _y}, _} -> x==col_num end)
    others = Map.filter(screen, fn {{x, _y}, _} -> x != col_num end)

    map(col, fn {{x, y}, v} -> {{x, rem(y+amount, @rows)}, v} end) |> Map.new
    |> Map.merge(others)
  end

  def draw(screen) do
    for y<-0..@rows-1 do
      for x<-0..@cols-1 do
        if screen[{x,y}], do: "x", else: "."
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
