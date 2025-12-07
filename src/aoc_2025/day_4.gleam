import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Coords =
  #(Int, Int)

pub type Grid =
  dict.Dict(Coords, String)

fn neighbours(x: Int, y: Int, grid: Grid) -> List(String) {
  [
    dict.get(grid, #(x - 1, y - 1)),
    dict.get(grid, #(x, y - 1)),
    dict.get(grid, #(x + 1, y - 1)),

    dict.get(grid, #(x - 1, y)),
    dict.get(grid, #(x + 1, y)),

    dict.get(grid, #(x - 1, y + 1)),
    dict.get(grid, #(x, y + 1)),
    dict.get(grid, #(x + 1, y + 1)),
  ]
  |> list.filter(result.is_ok)
  |> list.map(fn(r) { result.unwrap(r, ".") })
}

pub fn parse(input: String) -> Grid {
  input
  |> string.split("\n")
  |> list.index_map(fn(line, y) {
    string.to_graphemes(line)
    |> list.index_map(fn(value, x) { #(#(x, y), value) })
  })
  |> list.flatten
  |> dict.from_list
}

fn accessible_rolls(grid: Grid) -> List(Coords) {
  dict.keys(grid)
  |> list.filter(fn(coords) {
    dict.get(grid, coords) |> result.unwrap(".") == "@"
  })
  |> list.filter(fn(coords) {
    let #(x, y) = coords
    let neighbours = neighbours(x, y, grid)
    neighbours
    |> list.count(fn(neighbour) { neighbour == "@" })
    < 4
  })
}

pub fn pt_1(grid: Grid) {
  accessible_rolls(grid)
  |> list.length
}

pub fn pt_2(grid: Grid) {
  do_traverse(grid, accessible_rolls(grid), 0)
}

fn do_traverse(grid: Grid, rolls_removed: List(Coords), num_rolls_removed: Int) {
  use <- bool.guard(
    when: list.is_empty(rolls_removed),
    return: num_rolls_removed,
  )

  let step_num_rolls_removed = list.length(rolls_removed)
  let step_grid: Grid =
    list.fold(
      rolls_removed,
      from: grid,
      with: fn(step_grid, removed_roll_coords) {
        dict.upsert(in: step_grid, update: removed_roll_coords, with: fn(_) {
          "."
        })
      },
    )

  do_traverse(
    step_grid,
    accessible_rolls(step_grid),
    num_rolls_removed + step_num_rolls_removed,
  )
}
