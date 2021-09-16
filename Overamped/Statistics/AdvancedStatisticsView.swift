import OverampedCore
import Persist
import SwiftUI

struct AdvancedStatisticsView: View {
    @PersistStorage(persister: .replacedLinks)
    private var replacedLinks: [ReplacedLinksEvent]

    @PersistStorage(persister: .redirectedLinks)
    private var redirectedLinks: [Date: String]

    @State
    private var replacedDomainsToCountsMap: [DomainCount] = []

    @State
    private var redirectedDomainsToCountsMap: [DomainCount] = []

    @Binding
    private var showEmptyMessage: Bool

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

                ClearAdvancedStatisticsView()
                    .buttonStyle(BorderedButtonStyle())
            }
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
            let allDomains = redirectedLinks.values
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

    init(showEmptyMessage: Binding<Bool>) {
        _showEmptyMessage = showEmptyMessage
    }
}

struct AdvancedStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedStatisticsView(showEmptyMessage: .constant(true))
    }
}
