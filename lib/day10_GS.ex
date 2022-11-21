defmodule Day10_GS do
  import Enum
  @re_value ~r/value (\d+) goes to bot (\d+)/
  @re_handoff ~r/bot (\d+) gives low to ([a-z]+) (\d+) and high to ([a-z]+) (\d+)/

  def run do
    main_proc = self()

    input_parse = fn [_, val, bot] -> {String.to_integer(val), String.to_integer(bot)} end

    handoff_parse = fn [_, bot, rec1_type, rec1_num, rec2_type, rec2_num] ->
      {String.to_integer(bot),
       rec1_type, String.to_integer(rec1_num),
       rec2_type, String.to_integer(rec2_num)}
    end

    data = File.read!("data/day10.txt") |> String.trim()
    inputs   = Regex.scan(@re_value, data)   |> map(input_parse)
    handoffs = Regex.scan(@re_handoff, data) |> map(handoff_parse)

    bots = handoffs
           |> map(&elem(&1, 0))
           |> reduce(%{}, fn bot_num, acc -> acc |> Map.put(bot_num, elem(Bot.start(bot_num), 1)) end)

    make_handoff = fn
      bots, "bot", id     -> {"bot",    id, bots[id]}
       _   , "output", id -> {"output", id, main_proc}
    end

    do_handoff = fn {bot_id, t1, id1, t2, id2} ->
      Bot.set_handoffs(bots[bot_id],
                       make_handoff.(bots, t1, id1),
                       make_handoff.(bots, t2, id2))
    end

    each(handoffs, do_handoff)
    each(inputs, fn {val, id} -> Bot.pass_chip(bots[id], val) end)

    %{0 => a, 1=>b, 2=>c} = collect_n_results(21)
    a*b*c
  end

  def collect_n_results(n), do: collect_n_results(n, %{})
  def collect_n_results(n, m) when map_size(m) == n, do: m
  def collect_n_results(n, m) do
    receive do
      {:output, bin_val, num} -> collect_n_results(n, m |> Map.put(bin_val, num))
      other                   -> {:unexpected_message, other, m}
      after 100               -> {:timed_out, m}
    end
  end
end

defmodule Bot do
  use GenServer

  def start(bot_num),            do: GenServer.start(Bot, bot_num)
  def set_handoffs(pid, lo, hi), do: GenServer.cast(pid, {:set_handoffs, lo, hi})
  def pass_chip(pid, val),       do: GenServer.cast(pid, {:chip, val})

  def init(bot_num), do: {:ok, %{id: bot_num, vals: []}}

  def handle_cast({:set_handoffs, lo, hi}, state) do
    {:noreply, state |> Map.put(:lo, lo) |> Map.put(:hi, hi)}
  end

  def handle_cast({:chip, val}, state) do
    new_vals = [val | state.vals]

    if length(new_vals) == 2 do
      {lo_val, hi_val} = Enum.min_max(new_vals)
      handoff(state.lo, lo_val)
      handoff(state.hi, hi_val)
      if {17,61} == {lo_val, hi_val}, do: IO.puts("Bot #{state.id} handled {17,61}")
    end

    {:noreply, Map.put(state, :vals, new_vals)}
  end

  defp handoff({"bot",   _bot_num, pid}, val), do: Bot.pass_chip(pid, val)
  defp handoff({"output", bin_num, pid}, val), do: send(pid, {:output, bin_num, val})
end
