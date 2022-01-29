import Combine
import Persist
import SwiftUI
import OverampedCore

struct EventsLogView: View {
    @StateObject private var eventsLog = EventsLog()

    var body: some View {
        VStack {
            if let events = eventsLog.events {
                if events.isEmpty, eventsLog.searchText.isEmpty {
                    VStack {
                        Spacer()
                        Text("No events logged.")
                            .foregroundColor(Color(.placeholderText))
                            .font(.title3)
                        Spacer()
                    }
                } else {
                    VStack {
                        if events.isEmpty, !eventsLog.searchText.isEmpty {
                            Spacer()
                            Text("No events found matching search.")
                                .foregroundColor(Color(.placeholderText))
                                .font(.title3)
                            Spacer()
                        } else {
                            eventsView(events)
                        }
                    }
                    .searchable(text: $eventsLog.searchText)
                }
            } else {
                Spacer()

                ProgressView("Loading...")

                Spacer()
            }
        }
        .navigationTitle("Events Log")
    }

    @ViewBuilder
    private func eventsView(_ events: [Event]) -> some View {
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
                let events = indexSet.map { events[$0] }
                eventsLog.deleteEvents(events)
            }
        }
    }

    @ViewBuilder
    private func replacedLinksView(_ event: ReplacedLinksEvent) -> some View {
        ForEach(Array(event.domains.enumerated()), id: \.offset) { tuple in
            let domain = tuple.element

            Text("Replaced link to \(domain)")
        }
        .onDelete { indexSet in
            var event = event
            event.domains.remove(atOffsets: indexSet)

            eventsLog.updateReplacedLinksEvent(event)
        }
    }
}

private final class EventsLog: ObservableObject {
    @Published private(set) var events: [Event]?

    @Published var searchText: String = ""

    @Persisted(persister: .replacedLinks)
    private var replacedLinks: [ReplacedLinksEvent]

    @Persisted(persister: .redirectedLinks)
    private var redirectedLinks: [RedirectLinkEvent]

    private var cancellables: Set<Combine.AnyCancellable> = []

    init() {
        let workQueue = DispatchQueue(label: "Events Log")

        $replacedLinks
            .publisher
            .receive(on: workQueue)
            .combineLatest(
                $redirectedLinks
                    .publisher
            )
            .map { parameters -> [Event] in
                let (replacedLinks, redirectedLinks) = parameters
                let allEvents = replacedLinks.map { Event.replacedLinks($0) } + redirectedLinks.map { Event.redirectedLink($0) }
                return allEvents.sorted(by: { $0.date > $1.date })
            }
            .combineLatest(
                $searchText
                    .prepend("")
                    .debounce(for: 0.3, scheduler: workQueue)
            )
            .map { parameters -> [Event] in
                var events = parameters.0
                let searchText = parameters.1

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
            .receive(on: RunLoop.main)
            .sink { events in
                withAnimation {
                    self.events = events
                }
            }
            .store(in: &cancellables)
    }

    func deleteEvents(_ events: [Event]) {
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

    func updateReplacedLinksEvent(_ event: ReplacedLinksEvent) {
        guard let index = replacedLinks.firstIndex(where: { $0.id == event.id }) else { return }

        if event.domains.isEmpty {
            replacedLinks.remove(at: index)
        } else {
            replacedLinks[index] = event
        }
    }
}
