import gleam/int
import gleam/list
import gleam/regexp
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
  let assert Ok(regex) = regexp.from_string("^(\\d+)\\1$")
  run(ranges, regex)
}

pub fn pt_2(ranges: List(Range)) {
  let assert Ok(regex) = regexp.from_string("^(\\d+)\\1+$")
  run(ranges, regex)
}

fn run(ranges: List(Range), invalid_ids_regex: regexp.Regexp) -> Int {
  let invalid_ids =
    ranges
    |> list.map(fn(range) {
      let ids = list.range(range.start, range.end)
      ids
      |> list.map(int.to_string)
      |> list.filter(fn(id) {
        regexp.check(with: invalid_ids_regex, content: id)
      })
      |> list.map(int.parse)
    })
    |> list.flatten

  invalid_ids
  |> list.map(fn(x) { result.unwrap(x, 0) })
  |> list.reduce(int.add)
  |> result.unwrap(0)
}
