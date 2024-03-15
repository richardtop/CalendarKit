extension Array {
    mutating func shift(_ offset: Int) {
        var offset = offset
        guard abs(offset) < count else { return }
        if offset < 0 { offset += count }
        self = Array(self[offset ..< count] + self[0 ..< offset])
    }
}
