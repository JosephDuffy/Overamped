import SwiftUI
import OverampedCore

struct SupportView: View {
    @State private var showShareSheet = false

    @AppStorage("SupportView.isShowingSurvey")
    private var isShowingSurvey = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("""
                    Overamped is developed by a single indie developer. If you're able to provide any extra support it is greatly appreciated.
                    """)

                Text("✈️ TestFlight Survey")
                    .font(.title)

                Text("A short survey is available for TestFlight users. It is 3 or less questions and will help decide the pricing model for Overamped.")

                NavigationLink(isActive: $isShowingSurvey) {
                    SurveyView()
                } label: {
                    Text("Complete Survey")
                }

                Text("Share")
                    .font(.title)

                Text("The easiest way to support Overamped is to help spread the word.")

                Button("\(Image(systemName: "square.and.arrow.up")) Share Overamped") {
                    showShareSheet = true
                }
                .buttonStyle(BorderedButtonStyle())

                if DistributionMethod.current == .debug {
                    Text("Write a Review")
                        .font(.title)

                    Text("Reviews are very important on the App Store. You can also rate Overamped without writing a review.")

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
