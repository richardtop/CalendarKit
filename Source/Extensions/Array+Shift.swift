import Foundation

extension Array {
  mutating func shiftLeft() {
    insert(removeFirst(), atIndex: 0)
  }

  mutating func shiftRight() {
    append(removeFirst())
  }
}
