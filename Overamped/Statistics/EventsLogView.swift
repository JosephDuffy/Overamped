import Combine
import Persist
import SwiftUI
import OverampedCore

enum Event: Identifiable {
    case replacedLinks(ReplacedLinksEvent)
    case redirectedLink(RedirectLinkEvent)

    var id: UUID {
        switch self {
        case .replacedLinks(let event):
            return event.id
        case .redirectedLink(let event):
            return event.id
        }
    }

    var date: Date {
        switch self {
        case .replacedLinks(let event):
            return event.date
        case .redirectedLink(let event):
            return event.date
        }
    }
}

struct EventsLogView: View {
    @PersistStorage(persister: .replacedLinks)
    private var replacedLinks: [ReplacedLinksEvent]

    @PersistStorage(persister: .redirectedLinks)
    private var redirectedLinks: [RedirectLinkEvent]

    @State private var searchText: String = ""

    private var events: [Event] {
        let allEvents = replacedLinks.map { Event.replacedLinks($0) } + redirectedLinks.map { Event.redirectedLink($0) }
        var events = allEvents.sorted(by: { $0.date > $1.date })

        if !searchText.isEmpty {
            events = events.filter { event -> Bool in
                switch event {
                case .replacedLinks(let event):
                    return event.domains.contains { $0.localizedCaseInsensitiveContains(searchText) }
                case .redirectedLink(let event):
                    return event.domain.localizedCaseInsensitiveContains(searchText)
                }
            }
        }

        return events
    }

    var body: some View {
        List {
            ForEach(events) { event in
                Section(event.date.formatted()) {
                    switch event {
                    case .replacedLinks(let event):
                        replacedLinksView(event)
                    case .redirectedLink(let event):
                        Text("Redirected link to \(event.domain)")
                    }
                }
            }
            .onDelete { indexSet in
                let events = indexSet.map { self.events[$0] }
                events.forEach { event in
                    switch event {
                    case .replacedLinks(let event):
                        // This would only be triggered when deleting the section, which shouldn't
                        // currently be possible because each link is displayed individually by a
                        // `ForEach` that has its own `onDelete` modifier.
                        guard let index = replacedLinks.firstIndex(where: { $0.id == event.id }) else { return }
                        replacedLinks.remove(at: index)
                    case .redirectedLink(let event):
                        guard let index = redirectedLinks.firstIndex(where: { $0.id == event.id }) else { return }
                        redirectedLinks.remove(at: index)
                    }
                }
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Events Log")
    }

    @ViewBuilder
    private func replacedLinksView(_ event: ReplacedLinksEvent) -> some View {
        ForEach(Array(event.domains.enumerated()), id: \.offset) { tuple in
            let domain = tuple.element

            Text("Replaced link to \(domain)")
        }
        .onDelete { indexSet in
            guard let index = replacedLinks.firstIndex(where: { $0.id == event.id }) else { return }

            var event = event
            event.domains.remove(atOffsets: indexSet)

            if event.domains.isEmpty {
                replacedLinks.remove(at: index)
            } else {
                replacedLinks[index] = event
            }
        }
    }
}
