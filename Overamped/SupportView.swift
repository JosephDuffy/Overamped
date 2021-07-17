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
