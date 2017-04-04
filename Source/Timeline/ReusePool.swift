import UIKit

class ReusePool<T: UIView> {
  var storage: [T]

  init() {
    storage = [T]()
  }

  func enqueue(views: [T]) {
    views.forEach{$0.frame = .zero}
    storage.append(contentsOf: views)
  }

  func dequeue() -> T {
    guard !storage.isEmpty else {return T()}
    return storage.removeLast()
  }
}
