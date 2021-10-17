import OverampedCore
import Persist
import SwiftUI

struct AdvancedStatisticsView: View {
    @PersistStorage(persister: .replacedLinks)
    private var replacedLinks: [ReplacedLinksEvent]

    @PersistStorage(persister: .redirectedLinks)
    private var redirectedLinks: [RedirectLinkEvent]

    @State
    private var replacedDomainsToCountsMap: [DomainCount] = []

    @State
    private var redirectedDomainsToCountsMap: [DomainCount] = []

    private var recentEvents: [EventsByRelativeDate] {
        let allEvents = replacedLinks.map { Event.replacedLinks($0) } + redirectedLinks.map { Event.redirectedLink($0) }
        return Event.recentEventsGroupedByRelativeDate(allEvents)
    }

    @Binding
    private var showEmptyMessage: Bool

    @Binding
    private var showEventsLog: Bool

    private struct DomainCount: Hashable, Comparable {
        static func < (lhs: AdvancedStatisticsView.DomainCount, rhs: AdvancedStatisticsView.DomainCount) -> Bool {
            if lhs.count == rhs.count {
                return lhs.domain > rhs.domain
            } else {
                return lhs.count < rhs.count
            }
        }

        let domain: String
        var count: Int
    }
    
    var body: some View {
        if replacedDomainsToCountsMap.isEmpty, redirectedDomainsToCountsMap.isEmpty {
            if showEmptyMessage {
                Text("Nothing to display. Visit some websites to collect statistics.")
                    .foregroundColor(Color(.secondaryLabel))
            }
        } else {
            VStack(alignment: .leading, spacing: 16) {
                if !recentEvents.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Events")
                            .font(.title2.weight(.semibold))

                        ForEach(recentEvents, id: \.relativeDate) { eventsGroup in
                            Text(eventsGroup.relativeDate)
                                .font(.headline.weight(.semibold))

                            ForEach(eventsGroup.events) { event in
                                switch event {
                                case .replacedLinks(let event):
                                    Text("• Replaced \(event.domains.count) links")
                                case .redirectedLink(let event):
                                    Text("• Redirected link to \(event.domain)")
                                }
                            }
                        }

                        if (replacedDomainsToCountsMap.count + redirectedDomainsToCountsMap.count) > 3 {
                            NavigationLink("View All \(Image(systemName: "arrow.forward"))", isActive: $showEventsLog) {
                                EventsLogView()
                            }
                        }
                    }
                }

                if !replacedDomainsToCountsMap.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Top Replaced Domains")
                            .font(.title2.weight(.semibold))

                        ForEach(Array(replacedDomainsToCountsMap.prefix(3).enumerated()), id: \.offset) { enumerated in
                            let (offset, domainAndCount) = enumerated
                            Text("**\(offset + 1).** \(domainAndCount.domain) (\(domainAndCount.count))")
                        }

                        if replacedDomainsToCountsMap.count > 3 {
                            NavigationLink("View All \(Image(systemName: "arrow.forward"))") {
                                List {
                                    ForEach(replacedDomainsToCountsMap, id: \.domain){ redirectedDomainsToCounts in
                                        HStack {
                                            Text(redirectedDomainsToCounts.domain)
                                            Spacer()
                                            Text(redirectedDomainsToCounts.count.formatted())
                                                .foregroundColor(Color(.secondaryLabel))
                                        }
                                    }
                                }
                                .navigationTitle("Replaced Domains")
                            }
                        }
                    }
                }

                if !redirectedDomainsToCountsMap.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Top Redirected Domains")
                            .font(.title2.weight(.semibold))

                        ForEach(Array(redirectedDomainsToCountsMap.prefix(3).enumerated()), id: \.offset) { enumerated in
                            let (offset, domainAndCount) = enumerated
                            Text("**\(offset + 1).** \(domainAndCount.domain) (\(domainAndCount.count))")
                        }

                        if redirectedDomainsToCountsMap.count > 3 {
                            NavigationLink("View All \(Image(systemName: "arrow.forward"))") {
                                List {
                                    ForEach(redirectedDomainsToCountsMap, id: \.domain){ redirectedDomainsToCounts in
                                        HStack {
                                            Text(redirectedDomainsToCounts.domain)
                                            Spacer()
                                            Text(redirectedDomainsToCounts.count.formatted())
                                                .foregroundColor(Color(.secondaryLabel))
                                        }
                                    }
                                }
                                .navigationTitle("Redirected Domains")
                            }
                        }
                    }
                }
            }
            .onOpenURL(perform: { url in
                guard let deepLink = DeepLink(url: url) else { return }

                switch deepLink {
                case .eventsLog:
                    showEventsLog = true
                default:
                    break
                }
            })
        }

        EmptyView().onReceive(_replacedLinks.persister.publisher) { replacedLinks in
            let allDomains = replacedLinks.flatMap { $0.domains }
            replacedDomainsToCountsMap = allDomains
                .reduce(into: [:], { partialResult, domain in
                    partialResult[domain, default: 0] += 1
                })
                .map { element in
                    DomainCount(domain: element.key, count: element.value)
                }
                .sorted(by: >)
        }

        EmptyView().onReceive(_redirectedLinks.persister.publisher) { redirectedLinks in
            let allDomains = redirectedLinks.map(\.domain)
            redirectedDomainsToCountsMap = allDomains
                .reduce(into: [:], { partialResult, domain in
                    partialResult[domain, default: 0] += 1
                })
                .map { element in
                    DomainCount(domain: element.key, count: element.value)
                }
                .sorted(by: >)
        }
    }

    init(showEmptyMessage: Binding<Bool>, showEventsLog: Binding<Bool>) {
        _showEmptyMessage = showEmptyMessage
        _showEventsLog = showEventsLog
    }
}

struct AdvancedStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedStatisticsView(showEmptyMessage: .constant(true), showEventsLog: .constant(false))
    }
}
