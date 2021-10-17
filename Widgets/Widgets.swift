import OverampedCore
import Persist
import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    @PersistStorage(persister: .replacedLinks)
    private var replacedLinks: [ReplacedLinksEvent]

    @PersistStorage(persister: .redirectedLinks)
    private var redirectedLinks: [RedirectLinkEvent]

    private var events: [Event] {
        let allEvents = replacedLinks.map { Event.replacedLinks($0) } + redirectedLinks.map { Event.redirectedLink($0) }
        return allEvents.sorted(by: { $0.date > $1.date })
    }

    func placeholder(in context: Context) -> Entry {
        Entry(events: events, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = Entry(events: events, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries = [
            Entry(events: events, configuration: ConfigurationIntent()),
        ]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let events: [Event]
    let configuration: ConfigurationIntent

    init(events: [Event], configuration: ConfigurationIntent) {
        self.events = events
        self.configuration = configuration
        date = events.first?.date ?? .now
    }
}

struct WidgetsEntryView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily

    let entry: Provider.Entry

    private var maxUserInterfaceLines: Int {
        switch family {
        case .systemSmall, .systemMedium:
            return 6
        case .systemLarge, .systemExtraLarge:
            return 12
        @unknown default:
            return 6
        }
    }

    private var titleFont: Font? {
        switch family {
        case .systemSmall:
            return .body.bold()
        case .systemMedium:
            return .headline.bold()
        case .systemLarge:
            return .title3.bold()
        case .systemExtraLarge:
            return .title.bold()
        @unknown default:
            return nil
        }
    }

    private var groupFont: Font? {
        switch family {
        case .systemSmall:
            return .callout.weight(.semibold)
        case .systemMedium, .systemLarge:
            return .body.weight(.semibold)
        case .systemExtraLarge:
            return .headline.weight(.semibold)
        @unknown default:
            return nil
        }
    }

    private var eventFont: Font? {
        switch family {
        case .systemSmall:
            return .subheadline
        case .systemMedium, .systemLarge:
            return .callout
        case .systemExtraLarge:
            return nil
        @unknown default:
            return nil
        }
    }

    private var padding: CGFloat {
        switch family {
        case .systemSmall:
            return 6
        case .systemMedium, .systemLarge, .systemExtraLarge:
            return 12
        @unknown default:
            return 6
        }
    }

    private var eventSpacing: CGFloat {
        switch family {
        case .systemSmall:
            return 2
        case .systemMedium, .systemLarge, .systemExtraLarge:
            return 4
        @unknown default:
            return 0
        }
    }

    private var useSymbols: Bool {
        family == .systemSmall
    }

    @ViewBuilder
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: eventSpacing) {
                Text("Recent Events")
                    .font(titleFont)

                ForEach(
                    Event.recentEventsGroupedByRelativeDate(entry.events, maxUserInterfaceLines: maxUserInterfaceLines),
                    id: \.relativeDate
                ) { eventsGroup in
                    VStack(alignment: .leading) {
                        Text(eventsGroup.relativeDate)
                            .font(groupFont)

                        ForEach(eventsGroup.events) { event in
                            textForEvent(event)
                                .font(eventFont)
                        }
                    }
                    .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            Spacer()
        }
        .padding(padding)
    }

    @ViewBuilder
    private func textForEvent(_ event: Event) -> some View {
        switch event {
        case .replacedLinks(let event):
            if useSymbols {
                Label("\(event.domains.count) links", systemImage: "arrow.3.trianglepath")
            } else {
                Text("Replaced \(event.domains.count) links")
            }
        case .redirectedLink(let event):
            if useSymbols {
                Label(event.domain, systemImage: "arrow.uturn.forward")
            } else {
                Text("Redirected link to \(event.domain)")
            }
        }
    }
}

@main
struct Widgets: Widget {
    let kind: String = "Widgets"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("Recent Events")
    }
}

struct Widgets_Previews: PreviewProvider {
    private static var previewEntry: Entry {
        let events: [Event] = [
            .redirectedLink(RedirectLinkEvent(id: UUID(), date: .now.addingTimeInterval(-34), domain: "amp.reddit.com")),
            .replacedLinks(ReplacedLinksEvent(id: UUID(), date: .now.addingTimeInterval(-62), domains: ["amp.reddit.com"])),
            .replacedLinks(ReplacedLinksEvent(id: UUID(), date: .now.addingTimeInterval(-121), domains: ["amp.reddit.com", "bbc.co.uk"])),
            .replacedLinks(ReplacedLinksEvent(id: UUID(), date: .now.addingTimeInterval(-262), domains: ["amp.reddit.com"])),
            .replacedLinks(ReplacedLinksEvent(id: UUID(), date: .now.addingTimeInterval(-265), domains: ["amp.reddit.com", "bbc.co.uk"])),
        ]
        return Entry(events: events, configuration: ConfigurationIntent())
    }

    static var previews: some View {
        WidgetsEntryView(entry: previewEntry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        WidgetsEntryView(entry: previewEntry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        WidgetsEntryView(entry: previewEntry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
