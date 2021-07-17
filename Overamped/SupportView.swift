import SwiftUI

struct SupportView: View {
    @State private var showShareSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("""
                    Overamped is developed by a single indie developer. If you're able to provide any extra support it is greatly appreciated.
                    """)

                Text("Share")
                    .font(.title)

                Text("The easiest way to support Overamped is to help spread the word.")

                Button("\(Image(systemName: "square.and.arrow.up")) Share Overamped") {
                    showShareSheet = true
                }
                .buttonStyle(BorderedButtonStyle())

                Text("Write a Review")
                    .font(.title)

                Text("Reviews are very important on the App Store, plus I love to read them.")

                Link(
                    destination: URL(string: "https://itunes.apple.com/app/id1573901090?action=write-review&mt=8")!,
                    label: {
                        Text("\(Image(systemName: "square.and.pencil")) Review Overamped")
                    }
                )
                    .buttonStyle(BorderedButtonStyle())

                Text("Having an issue? [Submit feedback instead](overamped:feedback).")
                    .font(.caption)

                TipJarView()
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
