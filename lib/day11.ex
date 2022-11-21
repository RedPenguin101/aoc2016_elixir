defmodule Day11 do
  import Enum
  @example %{:elevator => 1,
             1 => MapSet.new(["HM", "LM"]),
             2 => MapSet.new(["HG"]),
             3 => MapSet.new(["LG"]),
             4 => MapSet.new([])}

  @input %{:elevator => 1,
           1 => MapSet.new(["TG", "TM", "PG", "SG"]),
           2 => MapSet.new(["PM", "SM"]),
           3 => MapSet.new(["pG", "pM", "RG", "RM"]),
           4 => MapSet.new([])}

  @input2 %{:elevator => 1,
            1 => MapSet.new(["TG", "TM", "PG", "SG", "EG", "EM", "DG", "DM"]),
            2 => MapSet.new(["PM", "SM"]),
            3 => MapSet.new(["pG", "pM", "RG", "RM"]),
            4 => MapSet.new([])}

  def scratch do
    search(@input)
  end

  def winner_from(floors) do
    %{:elevator => 4,
      1 => MapSet.new([]),
      2 => MapSet.new([]),
      3 => MapSet.new([]),
      4 => MapSet.new(concat([floors[1],floors[2],floors[3],floors[4]]))}
  end

  # https://eddmann.com/posts/advent-of-code-2016-day-11-radioisotope-thermoelectric-generators/
  # floor can simply be represented as a unique state based on the total
  # number of generators and microchips that are on that floor (each pair
  # are replaceable).
  def unique_state(floors) do
    cfo = fn floor -> floor |> map(fn <<_, t>> -> t end) |> frequencies() end
    reduce(1..4, floors, &Map.update!(&2, &1, cfo))
  end

  def search(init_floors) do
    movelist    = [{[], init_floors, 0}]
    seen_states =  MapSet.new([unique_state(init_floors)])

    search(movelist, winner_from(init_floors), seen_states)
  end

  def search([next_ml | other_movelists], winner, seen_states) do
    new_mls = new_movelists(next_ml, seen_states)

    new_seen_states = new_mls
                      |> map(&elem(&1, 1))
                      |> map(&unique_state/1)
                      |> MapSet.new()
                      |> MapSet.union(seen_states)

    win? = find(new_mls, false, fn {_, flrs, _} -> flrs == winner end)

    cond do
      win? -> win?
      :else -> search(other_movelists++new_mls, winner, new_seen_states)
    end
  end

  def new_movelists({move_seq, floors, count}, seen_states) do
    movelist_from_move = fn move -> {[move | move_seq], apply_move(floors, move), count+1} end
    seen? = fn {_,floors2,_} -> MapSet.member?(seen_states, unique_state(floors2)) end

    floors
    |> options_for_move
    |> map(movelist_from_move)
    |> reject(seen?)
  end

  def options_for_move(floors) do
    safe? = fn floors ->
      floors |> Map.delete(:elevator) |> Map.values |> Enum.all?(&floor_safe?/1)
    end

    only_safe = fn move -> safe?.(apply_move(floors, move)) end

    floors
    |> find_moves
    |> filter(only_safe)
  end

  def floor_safe?(floor) do
    is_chip? = fn s -> String.ends_with?(s, "M") end
    gen_of_chip = fn <<x, "M">> -> <<x, "G">> end

    chips = floor |> filter(is_chip?)
    gens =  floor |> reject(is_chip?)
    needed_gens =  chips |> map(gen_of_chip) |> MapSet.new()

    empty?(gens) || MapSet.subset?(needed_gens, floor)
  end

  def apply_move(floors, {direction, cargo}) do
    floor =  floors.elevator
    new_floor = floor + direction
    add_cargo = &(MapSet.union(&1, cargo))
    remove_cargo = &(MapSet.difference(&1, cargo))

    floors
    |> Map.put(:elevator, new_floor)
    |> Map.update!(new_floor, add_cargo)
    |> Map.update!(floor, remove_cargo)
  end

  def find_moves(floors) do
    things_to_move = floors[floors.elevator]
                     |> Combo.subsets()
                     |> filter(&(MapSet.size(&1) < 3))

    case floors.elevator do
      1 -> map(things_to_move, &{1, &1})
      4 -> map(things_to_move, &{-1, &1})
      _ -> map(things_to_move, &{-1, &1}) ++ map(things_to_move, &{1, &1})
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
