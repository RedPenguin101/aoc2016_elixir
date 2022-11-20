defmodule Day10 do
  import Enum
  @re_value ~r/value (\d+) goes to bot (\d+)/
  @re_handoff ~r/bot (\d+) gives low to ([a-z]+) (\d+) and high to ([a-z]+) (\d+)/
  @re_bots ~r/bot (\d+)/
  @re_bins ~r/output (\d+)/

  def part1 do
    input_parse = fn [_, val, bot] -> {String.to_integer(val), String.to_integer(bot)} end

    handoff_parse = fn [_, bot, rec1_type, rec1_num, rec2_type, rec2_num] ->
      {String.to_integer(bot), rec1_type, String.to_integer(rec1_num), rec2_type,
       String.to_integer(rec2_num)}
    end

    query = {17, 61}
    data = File.read!("data/day10.txt") |> String.trim()
    bots = Regex.scan(@re_bots, data) |> map(&List.last/1) |> map(&String.to_integer/1) |> uniq

    bins = Regex.scan(@re_bins, data) |> map(&List.last/1) |> map(&String.to_integer/1) |> MapSet.new()

    inputs = Regex.scan(@re_value, data) |> map(input_parse)
    handoffs = Regex.scan(@re_handoff, data) |> map(handoff_parse)

    bots = reduce(bots, %{}, &Map.put(&2, &1, new_bot(&1, query, self())))

    get_ref = fn
      "output", num -> num
      "bot", num -> bots[num]
    end

    each(handoffs, fn {from, lo_t, lo, hi_t, hi} ->
      send(bots[from], {:set_handoffs, get_ref.(lo_t, lo), get_ref.(hi_t, hi)})
    end)

    each(inputs, fn {val, bot_num} -> send(bots[bot_num], {:chip, val}) end)

    ans = collect_answer(%{}, bins)
    ans[0] * ans[1] * ans[2]
  end

  def collect_answer(state, waiting_for) do
    if Enum.empty?(waiting_for) do
      state
    else
      receive do
        {bin, val} ->
          collect_answer(Map.put(state, bin, val), MapSet.delete(waiting_for, bin))
      end
    end
  end

  def new_bot(num, query, callback), do: spawn(fn -> bot_loop(num, query, callback) end)

  def bot_loop(num, query, callback), do: bot_loop(num, false, false, false, query, callback)

  def bot_loop(num, lo, hi, first_val, query, callback) do
    receive do
      {:set_handoffs, new_lo, new_hi} ->
        bot_loop(num, new_lo, new_hi, first_val, query, callback)

      {:chip, new_val} when is_number(first_val) ->
        lo_val = Kernel.min(new_val, first_val)
        hi_val = Kernel.max(new_val, first_val)

        if is_pid(lo) do
          send(lo, {:chip, lo_val})
        else
          send(callback, {lo, lo_val})
        end

        if is_pid(hi) do
          send(hi, {:chip, hi_val})
        else
          send(callback, {hi, hi_val})
        end

        if query == {lo_val, hi_val}, do: IO.inspect({num, :did, query})

      {:chip, new_val} ->
        bot_loop(num, lo, hi, new_val, query, callback)
    end
  end
end
