import Foundation

public enum Event: Identifiable, Hashable {
    case replacedLinks(ReplacedLinksEvent)
    case redirectedLink(RedirectLinkEvent)

    public var id: UUID {
        switch self {
        case .replacedLinks(let event):
            return event.id
        case .redirectedLink(let event):
            return event.id
        }
    }

    public var date: Date {
        switch self {
        case .replacedLinks(let event):
            return event.date
        case .redirectedLink(let event):
            return event.date
        }
    }
}

public struct EventsByRelativeDate: Hashable {
    public let relativeDate: String
    public fileprivate(set) var events: [Event]
}

extension Event {
    public static func recentEventsGroupedByRelativeDate(_ events: [Event], maxEventsCount: Int = 3) -> [EventsByRelativeDate] {
        events
            .sorted(by: { $0.date > $1.date })
            .prefix(maxEventsCount)
            .map { event -> (String, Event) in
                let formattedDate = event.date.formatted(.relative(presentation: .numeric, unitsStyle: .wide))
                return (formattedDate, event)
            }
            .reduce(into: [EventsByRelativeDate]()) { partialResult, tuple in
                let (formattedDate, event) = tuple
                if let sameDateIndex = partialResult.firstIndex(where: { $0.relativeDate == formattedDate }) {
                    partialResult[sameDateIndex].events.append(event)
                } else {
                    let eventsByRelativeDate = EventsByRelativeDate(relativeDate: formattedDate, events: [event])
                    partialResult.append(eventsByRelativeDate)
                }
            }
    }

    public static func recentEventsGroupedByRelativeDate(_ events: [Event], maxUserInterfaceLines: Int) -> [EventsByRelativeDate] {
        var eventsByRelativeDate = [EventsByRelativeDate]()

        let eventsWithFormattedDate = events
            .sorted(by: { $0.date > $1.date })
            .map { event -> (String, Event) in
                let formattedDate = event.date.formatted(.relative(presentation: .numeric, unitsStyle: .wide))
                return (formattedDate, event)
            }

        var linesCount = 0
        for tuple in eventsWithFormattedDate {
            let (formattedDate, event) = tuple
            if let sameDateIndex = eventsByRelativeDate.firstIndex(where: { $0.relativeDate == formattedDate }) {
                eventsByRelativeDate[sameDateIndex].events.append(event)
                linesCount += 1
            } else if maxUserInterfaceLines - linesCount >= 2 {
                let eventByRelativeDate = EventsByRelativeDate(relativeDate: formattedDate, events: [event])
                eventsByRelativeDate.append(eventByRelativeDate)
                linesCount += 2
            } else {
                break
            }

            if linesCount >= maxUserInterfaceLines {
                break
            }
        }

        return eventsByRelativeDate
    }
}
