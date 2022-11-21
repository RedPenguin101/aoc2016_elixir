defmodule Day11 do
  import Enum
  import MapSet, only: [union: 2, difference: 2]
  import Map,    only: [update!: 3, values: 1, put: 3, delete: 2]

  # convenience utils
  def first(tuple),  do: elem(tuple, 0)
  def second(tuple), do: elem(tuple, 1)
  def last(tuple),   do: elem(tuple, tuple_size(tuple)-1)
  def empty_set,     do: set([])
  def set(xs),       do: MapSet.new(xs)

  def part1 do
    init_state =  %{:elevator => 1,
                    1 => set(["TG", "TM", "PG", "SG"]),
                    2 => set(["PM", "SM"]),
                    3 => set(["pG", "pM", "RG", "RM"]),
                    4 => empty_set()}

    init_state |> search |> last
  end

  def part2 do
    init_state =  %{:elevator => 1,
                    1 => set(["TG", "TM", "PG", "SG", "EG", "EM", "DG", "DM"]),
                    2 => set(["PM", "SM"]),
                    3 => set(["pG", "pM", "RG", "RM"]),
                    4 => empty_set()}
    init_state |> search |> last
  end

  def target_state(floors) do
    all = [floors[1],floors[2],floors[3],floors[4]] |> concat |> set

    %{:elevator => 4,
      1 => empty_set(),
      2 => empty_set(),
      3 => empty_set(),
      4 => all}
  end

  def search(init_floors) do
    init_path   = {[], init_floors, 0}
    seen_states =  set([unique_state(init_floors)])

    search([init_path], target_state(init_floors), seen_states)
  end

  def search([path | other_paths], winner, seen_states) do
    new_paths = find_new_paths(path, seen_states)

    new_seen_states = new_paths
                      |> map(&second/1)
                      |> map(&unique_state/1)
                      |> set()
                      |> union(seen_states)

    win? = find(new_paths, false, fn {_, flrs, _} -> flrs == winner end)

    cond do
      win? -> win?
      :else -> search(other_paths++new_paths, winner, new_seen_states)
    end
  end

  def find_new_paths({move_seq, floors, count}, seen_states) do
    path_from_move = fn move -> {[move | move_seq], apply_move(floors, move), count+1} end
    seen? = fn {_,floors2,_} -> member?(seen_states, unique_state(floors2)) end

    floors
    |> safe_moves
    |> map(path_from_move)
    |> reject(seen?)
  end

  # https://eddmann.com/posts/advent-of-code-2016-day-11-radioisotope-thermoelectric-generators/
  # floor can simply be represented as a unique state based on the total
  # number of generators and microchips that are on that floor (each pair
  # are replaceable).
  def unique_state(floors) do
    cfo = fn floor -> floor |> map(fn <<_, t>> -> t end) |> frequencies() end
    reduce(1..4, floors, &update!(&2, &1, cfo))
  end

  def apply_move(floors, {direction, cargo}) do
    current_floor =  floors.elevator
    new_floor = current_floor + direction
    add_cargo = &(union(&1, cargo))
    remove_cargo = &(difference(&1, cargo))

    floors
    |> put(:elevator, new_floor)
    |> update!(new_floor, add_cargo)
    |> update!(current_floor, remove_cargo)
  end

  def safe_moves(floors) do
    safe? = fn floors ->
      floors |> delete(:elevator) |> values |> all?(&floor_safe?/1)
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
    needed_gens =  chips |> map(gen_of_chip) |> set()

    empty?(gens) || MapSet.subset?(needed_gens, floor)
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
