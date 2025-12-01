import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string

pub type Direction {
  Left
  Right
}

pub type Rotate {
  Rotate(direction: Direction, amount: Int)
}

pub fn parse(input: String) {
  input
  |> string.split(on: "\n")
  |> list.map(with: fn(command) {
    case string.split_once(command, on: "L") {
      Ok(#(_, amount)) -> Rotate(Left, int.parse(amount) |> result.unwrap(0))
      Error(_) -> {
        let end =
          string.slice(command, at_index: 1, length: string.length(command))
        Rotate(Right, int.parse(end) |> result.unwrap(0))
      }
    }
  })
}

pub fn pt_1(input: List(Rotate)) {
  let state =
    input
    |> list.fold([50], fn(state, rotate) {
      let position = list.first(state) |> result.unwrap(0)
      let new_position = case rotate {
        Rotate(Left, amount) -> { position + 100 - amount } % 100
        Rotate(Right, amount) -> { position + amount } % 100
      }
      [new_position, ..state]
    })
    |> list.reverse

  state
  |> list.count(fn(x) { x == 0 })
}

pub fn pt_2(input: List(Rotate)) {
  let state =
    input
    |> list.fold([#(50, 0)], fn(state, rotate) {
      let #(previous_position, _) = list.first(state) |> result.unwrap(#(50, 0))

      let raw_new_position = case rotate {
        Rotate(Left, amount) -> previous_position - amount
        Rotate(Right, amount) -> previous_position + amount
      }

      let new_position = raw_new_position % 100
      let new_position = case int.compare(new_position, 0) {
        order.Lt -> 100 + new_position
        order.Eq -> new_position
        order.Gt -> new_position
      }

      let zero_crossings =
        list.range(previous_position, raw_new_position)
        |> list.fold(0, fn(sum, value) {
          case value % 100 {
            0 if value != previous_position -> sum + 1
            _ -> sum
          }
        })

      [#(new_position, zero_crossings), ..state]
    })
    |> list.reverse

  state
  |> list.map(fn(x) {
    let #(_, times_crossed_zero) = x
    times_crossed_zero
  })
  |> list.reduce(fn(acc, x) { acc + x })
  |> result.unwrap(0)
}
