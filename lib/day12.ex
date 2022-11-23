defmodule Day12 do
  import Enum
  import Utils

  @registers  %{"a" => 0, "b" => 0, "c" => 0, "d" => 0}
  @registers2 %{"a" => 0, "b" => 0, "c" => 1, "d" => 0}

  def run do
    instructions = File.read!("data/day12.txt")
                   |> String.trim
                   |> String.split("\n")
                   |> map(compose(&String.split/1, &List.to_tuple/1))
                   |> List.to_tuple()

    %{"a" => a} = process(@registers, 0, instructions)
    %{"a" => b} = process(@registers2, 0, instructions)
    %{part1: a, part2: b}
  end

  def process(r,ip,instructions) when ip >= tuple_size(instructions), do: r

  def process(registers, ip, instructions) do
    get_value = fn reg, a -> Map.get(reg, a) || String.to_integer(a) end

    {new_reg, new_ip} = case elem(instructions, ip) do
      {"cpy", a, b} -> {Map.put(registers, b, get_value.(registers, a)), ip+1}
      {"inc", a}    -> {Map.update!(registers, a, &(&1 + 1)), ip+1}
      {"dec", a}    -> {Map.update!(registers, a, &(&1 - 1)), ip+1}
      {"jnz", a, b} ->
        {registers,
         (if get_value.(registers, a) != 0, do: ip + get_value.(registers, b), else: ip + 1)}
    end

    process(new_reg, new_ip, instructions)
  end
end
