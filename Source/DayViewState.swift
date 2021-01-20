import Foundation

public protocol DayViewStateUpdating: AnyObject {
  func move(from oldDate: Date, to newDate: Date)
}

public final class DayViewState {
  public private(set) var calendar: Calendar
//    willSet {} // TODO: I think this needs to be implemented, cause timezone can change without creating a new state object
  public private(set) var selectedDate: Date
  private var clients = [DayViewStateUpdating]()

  public init(date: Date = Date(), calendar: Calendar = Calendar.autoupdatingCurrent) {
    let date = date.dateOnly(calendar: calendar)
    self.calendar = calendar
    self.selectedDate = date
  }

  public func move(to date: Date) {
    let date = date.dateOnly(calendar: calendar)
//    if (date == selectedDate) { return } // TODO: If necessary? Just trying to make sure that willMoveTo not be called if we are already on this page
    notify(clients: clients, moveTo: date)
    selectedDate = date
  }

  public func client(client: DayViewStateUpdating, didMoveTo date: Date) {
    let date = date.dateOnly(calendar: calendar)
    notify(clients: allClientsWithout(client: client),
           moveTo: date)
    selectedDate = date
  }

  public func subscribe(client: DayViewStateUpdating) {
    clients.append(client)
  }

  public func unsubscribe(client: DayViewStateUpdating) {
    clients = allClientsWithout(client: client)
  }

  private func allClientsWithout(client: DayViewStateUpdating) -> [DayViewStateUpdating] {
    return clients.filter{$0 !== client}
  }

  private func notify(clients: [DayViewStateUpdating], moveTo date: Date) {
    for client in clients {
      client.move(from: selectedDate, to: date)
    }
  }
}
