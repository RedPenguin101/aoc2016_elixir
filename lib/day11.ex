defmodule Day11 do
  import Enum
  @example %{:elevator => 1,
             1 => MapSet.new(["HM", "LM"]),
             2 => MapSet.new(["HG"]),
             3 => MapSet.new(["LG"]),
             4 => MapSet.new([])}

  # The first floor contains
  #   a thulium generator,
  #   a thulium-compatible microchip,
  #   a plutonium generator,
  #   a strontium generator.
  # The second floor contains
  #   a plutonium-compatible microchip and
  #   a strontium-compatible microchip.
  # The third floor contains
  #   a promethium generator,
  #   a promethium-compatible microchip,
  #   a ruthenium generator, and
  #   a ruthenium-compatible microchip.
  @input %{:elevator => 1,
           1 => MapSet.new(["TG", "TM", "PG", "SG"]),
           2 => MapSet.new(["PM", "SM"]),
           3 => MapSet.new(["pG", "pM", "RG", "RM"]),
           4 => MapSet.new([])}

  # Also On the first floor:
  #   An elerium generator.
  #   An elerium-compatible microchip.
  #   A dilithium generator.
  #   A dilithium-compatible microchip.

  @input2 %{:elevator => 1,
            1 => MapSet.new(["TG", "TM", "PG", "SG", "EG", "EM", "DG", "DM"]),
            2 => MapSet.new(["PM", "SM"]),
            3 => MapSet.new(["pG", "pM", "RG", "RM"]),
            4 => MapSet.new([])}

  def scratch do
    search(@input)
  end

  def winner_from(state) do
    %{:elevator => 4,
      1 => MapSet.new([]),
      2 => MapSet.new([]),
      3 => MapSet.new([]),
      4 => MapSet.new(concat([state[1],state[2],state[3],state[4]]))}
  end

  # https://eddmann.com/posts/advent-of-code-2016-day-11-radioisotope-thermoelectric-generators/
  # floor can simply be represented as a unique state based on the total
  # number of generators and microchips that are on that floor (each pair
  # are replaceable).
  def count_floor_objects(state) do
    cfo = fn floor -> floor |> map(fn <<_, t>> -> t end) |> frequencies() end
    reduce(1..4, state, &Map.update!(&2, &1, cfo))
  end

  def search(init_state) do
    movelist = [{[], init_state,0}]
    seen_states =  MapSet.new([count_floor_objects(init_state)])
    search(movelist, winner_from(init_state), seen_states)
  end

  def search([nxt|other_movelists], winner, seen_states) do
    winner? = fn {_, st, _} -> st == winner end
    new_mls = new_movelists(nxt, seen_states)

    w = find(new_mls, false, winner?)

    new_seen = new_mls
               |> map(&elem(&1, 1))
               |> map(&count_floor_objects/1)
               |> MapSet.new()
               |> MapSet.union(seen_states)

    cond do
      w -> w
      :else -> search(other_movelists++new_mls, winner, new_seen)
    end
  end

  def new_movelists({move_seq, state, count}, seen_states) do
    state
    |> options
    |> map(&{[&1|move_seq], new_state(state, &1), count+1})
    |> reject(&(MapSet.member?(seen_states, count_floor_objects(elem(&1, 1)))))
  end

  def options(state) do
    state
    |> moves
    |> filter(fn mv -> safe?(new_state(state, mv)) end)
  end

  def safe?(state) do
    state |> Map.delete(:elevator) |> Map.values |> Enum.all?(&floor_safe?/1)
  end

  def floor_safe?(floor) do
    chip? = fn s -> String.ends_with?(s, "M") end
    gen_of = fn <<x, "M">> -> <<x, "G">> end

    chips = floor |> filter(chip?)
    gens =  floor |> reject(chip?)
    needed_gens =  map(chips, gen_of) |> MapSet.new()
    empty?(gens) || MapSet.subset?(needed_gens, floor)
  end

  def new_state(state, {mv, cargo}) do
    new_floor = state.elevator + mv

    state
    |> Map.update!(new_floor, &(MapSet.union(&1, cargo)))
    |> Map.update!(state.elevator, &(MapSet.difference(&1, cargo)))
    |> Map.put(:elevator, new_floor)
  end

  def moves(state) do
    ss = state[state.elevator]
         |> Combo.subsets()
         |> filter(&(MapSet.size(&1) < 3))

    case state.elevator do
      1 -> map(ss, &{1, &1})
      4 -> map(ss, &{-1, &1})
      _ -> map(ss, &{-1, &1}) ++ map(ss, &{1, &1})
    end
  end
end

defmodule Combo do
  import Bitwise

  def subsets(set) do
    set_size =  MapSet.size(set)
    power_set_size = :math.pow(2, set_size) |> round

    elements = set |> MapSet.to_list

    for c <- 1..power_set_size-1 do
      for j <- 0..set_size-1, (c &&& (1 <<< j)) > 0 do
        Enum.at(elements, j)
      end |> MapSet.new()
    end
  end
end
