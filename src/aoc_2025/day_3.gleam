import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(bank) {
    string.to_graphemes(bank)
    |> list.map(fn(battery) { int.parse(battery) |> result.unwrap(0) })
  })
}

pub fn pt_1(banks: List(List(Int))) {
  banks
  |> list.map(fn(bank) { compute_joltage(bank, 2, 0) })
  |> int.sum
}

pub fn pt_2(banks: List(List(Int))) {
  banks
  |> list.map(fn(bank) { compute_joltage(bank, 12, 0) })
  |> int.sum
}

pub fn compute_joltage(bank: List(Int), num_batteries: Int, sum: Int) {
  use <- bool.guard(when: num_batteries == 0, return: sum)

  let assert Ok(max) =
    list.take(bank, list.length(bank) - num_batteries + 1)
    |> list.reduce(int.max)

  let #(_, remaining_batteries) = list.split_while(bank, fn(b) { b != max })
  let remaining_batteries = list.drop(remaining_batteries, 1)

  compute_joltage(remaining_batteries, num_batteries - 1, sum * 10 + max)
}
