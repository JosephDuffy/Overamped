import SwiftUI
import OverampedCore

struct SupportView: View {
    @State private var showShareSheet = false

    @AppStorage("SupportView.isShowingSurvey")
    private var isShowingSurvey = false

    @AppStorage("HasSubmittedPricingSurvey")
    private var hasSubmittedPricingSurvey = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("""
                    Overamped is developed by a single indie developer. If you're able to provide any extra support it is greatly appreciated.
                    """)

                Text("✈️ Pricing Survey")
                    .font(.title)

                if hasSubmittedPricingSurvey {
                    Text("Thank you for completing the pricing survey.")
                } else {
                    Text("A short survey is available for TestFlight users. It is 2 questions and will help decide the pricing model for Overamped.")
                }

                NavigationLink(isActive: $isShowingSurvey) {
                    SurveyView()
                } label: {
                    Text("Complete Survey")
                }

                Text("Share")
                    .font(.title)

                Text("The easiest way to support Overamped is to share Overamped with friends and on social media.")

                Button("\(Image(systemName: "square.and.arrow.up")) Share Overamped") {
                    showShareSheet = true
                }
                .buttonStyle(BorderedButtonStyle())
                .background(
                    ActivityView(
                        isPresented: $showShareSheet,
                        items: {
                            [
                                "Download Overamped to disable AMP in Safari",
                                URLUIActivityItemSource(
                                    url: URL(string: "https://overamped.app")!
                                ),
                            ]
                        }
                    )
                )

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
