import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Range {
  Range(start: Int, end: Int)
}

pub fn parse(input: String) {
  input
  |> string.split(on: ",")
  |> list.map(fn(text) {
    let assert Ok(#(start, end)) = string.split_once(text, "-")
    let assert Ok(start) = int.parse(start)
    let assert Ok(end) = int.parse(end)
    Range(start, end)
  })
}

pub fn pt_1(ranges: List(Range)) {
  run(ranges, digits_repeated_twice)
}

pub fn pt_2(ranges: List(Range)) {
  run(ranges, digits_repeated_at_least_twice)
}

fn run(ranges: List(Range), invalid_ids_function: fn(String) -> Bool) -> Int {
  let invalid_ids =
    ranges
    |> list.map(fn(range) {
      let ids = list.range(range.start, range.end)
      ids
      |> list.map(int.to_string)
      |> list.filter(invalid_ids_function)
      |> list.map(int.parse)
    })
    |> list.flatten

  invalid_ids
  |> list.map(fn(x) { result.unwrap(x, 0) })
  |> list.reduce(int.add)
  |> result.unwrap(0)
}

fn digits_repeated_twice(id: String) -> Bool {
  case string.length(id) % 2 {
    1 -> False
    _ -> {
      let first_half =
        string.slice(id, at_index: 0, length: string.length(id) / 2)
      let second_half =
        string.slice(
          id,
          at_index: string.length(id) / 2,
          length: string.length(id) / 2,
        )
      first_half == second_half
    }
  }
}

type SubsequenceInfo {
  SubsequenceInfo(
    id: String,
    subsequence: String,
    num_sequence_repetitions: Int,
    id_is_repeated_digits: Bool,
  )
}

fn digits_repeated_at_least_twice(id: String) -> Bool {
  let length = string.length(id)
  case length {
    1 -> False
    _ -> {
      let maximum_cycle_length = length / 2

      let repeated_subsequences =
        list.range(1, maximum_cycle_length)
        |> list.map(fn(sequence_length) {
          string.slice(id, at_index: 0, length: sequence_length)
        })
        |> list.filter(fn(subsequence) {
          length % string.length(subsequence) == 0
        })
        |> list.map(fn(subsequence) {
          let num_sequence_repetitions = length / string.length(subsequence)

          SubsequenceInfo(
            id: id,
            subsequence: subsequence,
            num_sequence_repetitions: num_sequence_repetitions,
            id_is_repeated_digits: id
              == string.repeat(subsequence, times: num_sequence_repetitions),
          )
        })
        |> list.filter(fn(info) { info.id_is_repeated_digits })

      !list.is_empty(repeated_subsequences)
    }
  }
}
