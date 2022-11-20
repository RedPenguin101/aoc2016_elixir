defmodule Day10 do
  import Enum
  @re_value ~r/value (\d+) goes to bot (\d+)/
  @re_handoff ~r/bot (\d+) gives low to ([a-z]+) (\d+) and high to ([a-z]+) (\d+)/
  @re_bots ~r/bot (\d+)/
  @re_bins ~r/output (\d+)/

  def part1 do
    input_parse = fn [_, val, bot] -> {String.to_integer(val), String.to_integer(bot)} end
    handoff_parse = fn [_, bot, rec1_type, rec1_num, rec2_type, rec2_num] ->
      {String.to_integer(bot),
       rec1_type, String.to_integer(rec1_num),
       rec2_type, String.to_integer(rec2_num)}
    end

    query = {0,0}
    data = File.read!("data/day10.txt") |> String.trim
    bots = Regex.scan(@re_bots, data) |> map(&List.last/1) |> map(&String.to_integer/1) |> uniq
    bins = Regex.scan(@re_bins, data) |> map(&List.last/1) |> map(&String.to_integer/1) |> uniq
    inputs = Regex.scan(@re_value, data) |> map(input_parse)
    handoffs = Regex.scan(@re_handoff, data) |> map(handoff_parse)

    s = reduce(bins,
           reduce(bots, %{}, &(Map.put(&2, {:bot, &1}, new_bot(&1, query)))),
           &(Map.put(&2, {:bin, &1}, new_bin(&1))))

    bot = &(s[{:bot, &1}])
    bin = &(s[{:bin, &1}])
    get_ref = fn "output", num -> bin.(num)
                 "bot", num   -> bot.(num)
              end

    each(handoffs, fn {from, lo_t, lo, hi_t, hi}->
                     send(bot.(from), {:set_handoffs, get_ref.(lo_t, lo), get_ref.(hi_t, hi)})
                   end)

    each(inputs, fn {val, bot_num} -> send(bot.(bot_num), {:chip, val}) end)
  end

  def new_bot(num, query) do
    spawn(fn -> bot_loop(num, query) end)
  end

  def bot_loop(num, query), do: bot_loop(num, false, false, false, query)
  def bot_loop(num, lo, hi, first_val, query) do
    receive do
      {:set_handoffs, new_lo, new_hi} ->
        bot_loop(num, new_lo, new_hi, first_val, query)

      {:chip, new_val} when is_number(first_val) ->
        lo_val = Kernel.min(new_val, first_val)
        hi_val = Kernel.max(new_val, first_val)
        send(lo, {:chip, lo_val})
        send(hi, {:chip, hi_val})
        if query == {lo_val, hi_val}, do: IO.inspect({num, :did, query})

      {:chip, new_val} ->
        bot_loop(num, lo, hi, new_val, query)

    end
  end

  def new_bin(num) do
    spawn(fn -> bin_loop(num) end)
  end

  def bin_loop(num) do
    receive do
      {:chip, val} ->
        IO.inspect({:bin, num, :received, val})
    end
  end
end
