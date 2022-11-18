defmodule Day08 do
  import Enum

  @cols 50
  @rows 6

  def update_tuple(tuple, idx, fun) do
    current = elem(tuple, idx)
    put_elem(tuple, idx, fun.(current))
  end

  def part1 do
    File.read!("data/day08.txt")
    |> String.trim
    |> String.split("\n")
    |> map(&parse_row/1)
    |> reduce(%{}, &proc_instr/2)
    |> count
  end

  def part2 do
    File.read!("data/day08.txt")
    |> String.trim
    |> String.split("\n")
    |> map(&parse_row/1)
    |> reduce(%{}, &proc_instr/2)
    |> draw
  end

  def proc_instr({:rect,      {cols,rows}}, screen),  do: rect(screen, cols, rows)
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

    push = fn curr -> rem(curr + amount, wrap) end

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
    nums = Regex.run(~r/(\d+)[a-z| ]+(\d+)/, string)
           |> tl
           |> map(&String.to_integer/1)
           |> List.to_tuple

    case string do
      "rect "    <> _ -> {:rect, nums}
      "rotate c" <> _ -> {:col, nums}
      "rotate r" <> _ -> {:row, nums}
    end
  end
end
