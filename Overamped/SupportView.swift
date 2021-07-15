import SwiftUI

struct SupportView: View {
    @State private var showShareSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("""
                    Overamped is developed by a single indie developer. If you're able to provide any extra support it is greatly appreciated.
                    """)

                Text("Share")
                    .font(.title)

                Text("The easiest way to support Overamped is to help spread the word.")

                Button("Share Overamped") {
                    showShareSheet = true
                }

                Group {
                    Text("Tip Jar")
                        .font(.title)

                    Text("Overamped requires ongoing maintenance to keep up-to-date with changes to iOS and Google. Any extra financial support will help with this tremendously.")

                    Text("So far you have contributed £0.00 to Overamped.")

                    Text("One-off")
                        .font(.title2)

                    Text("These in-app purchases provide a single one-off payment.")

                    Text("Recurring")
                        .font(.title2)

                    Text("These in-app purchases provide a recurring payment.")
                }
            }
            .padding()
        }
        .navigationTitle("Support Overamped")
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
}
