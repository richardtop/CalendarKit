extension Array {
  mutating func shift(var amount: Int) {
    guard -count...count ~= amount else { return }
    if amount < 0 { amount += count }
    self = Array(self[amount ..< count] + self[0 ..< amount])
  }
}
