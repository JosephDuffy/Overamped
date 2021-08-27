import OverampedCore
import Persist
import SwiftUI

struct IgnoredHostnamesView: View {
    @PersistStorage(persister: .ignoredHostnames)
    private(set) var ignoredHostnames: [String]

    var body: some View {
        Group {
            if ignoredHostnames.isEmpty {
                Text("Overamped has not been disabled on any websites")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color(.secondaryLabel))
            } else {
                List {
                    ForEach(ignoredHostnames, id: \.self) { ignoredHostname in
                        Text(ignoredHostname)
                    }
                    .onDelete(perform: deleteIgnoredHostnames(atOffsets:))
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .constrainedToReadableWidth()
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Disabled Websites")
    }

    private func deleteIgnoredHostnames(atOffsets offsets: IndexSet) {
        ignoredHostnames.remove(atOffsets: offsets)
    }
}

struct IgnoredHostnamesView_Previews: PreviewProvider {
    static var previews: some View {
        IgnoredHostnamesView()
    }
}
