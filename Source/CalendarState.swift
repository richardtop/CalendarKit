import Foundation

protocol CalendarStateUpdating: class {
  func move(from oldDate: Date, to newDate: Date)
}

class CalendarState {

  private(set) var selectedDate: Date
  private var clients = [CalendarStateUpdating]()

  init(date: Date = Date()) {
    let date = date.dateOnly()
    self.selectedDate = date
  }

  func move(to date: Date) {
    let date = date.dateOnly()
    notify(clients: clients, moveTo: date)
    selectedDate = date
  }

  func client(client: CalendarStateUpdating, didMoveTo date: Date) {
    let date = date.dateOnly()
    notify(clients: allClientsWithout(client: client),
           moveTo: date)
    selectedDate = date
  }

  func subscribe(client: CalendarStateUpdating) {
    clients.append(client)
  }

  func unsubscribe(client: CalendarStateUpdating) {
    clients = allClientsWithout(client: client)
  }

  private func allClientsWithout(client: CalendarStateUpdating) -> [CalendarStateUpdating] {
    return clients.filter{$0 !== client}
  }

  private func notify(clients: [CalendarStateUpdating], moveTo date: Date) {
    for client in clients {
      client.move(from: selectedDate, to: date)
    }
  }
}
