import SwiftUI
import OverampedCore

struct SupportView: View {
    @State private var showShareSheet = false

    @SceneStorage("SupportView.isShowingSurvey")
    private var isShowingSurvey = false

    @AppStorage("HasSubmittedPricingSurvey")
    private var hasSubmittedPricingSurvey = false

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 0 : 12) {
                Text("""
                    Overamped is developed by a single indie developer. If you're able to provide any extra support it is greatly appreciated.
                    """)
                    .padding(.vertical, horizontalSizeClass == .regular ? 12 : 0)

                if horizontalSizeClass == .regular {
                    Divider()
                    HStack(alignment: .top) {
                        shareSection
                            .padding(.vertical, 12)
                        Divider()
                        reviewSection
                            .padding(.vertical, 12)
                    }
                    Divider()
                } else {
                    shareSection
                    reviewSection
                }

                TipJarView()
                    .padding(.vertical, horizontalSizeClass == .regular ? 12 : 0)
            }
            .padding()
        }
        .background(
            Color(.systemGroupedBackground)
        )
        .navigationTitle("Support Overamped")
    }

    @ViewBuilder
    private var shareSection: some View {
        VStack(alignment: horizontalSizeClass == .regular ? .leading : .leading) {
            Text("Share")
                .font(.title.weight(.semibold))

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
        }
    }

    @ViewBuilder
    private var reviewSection: some View {
        VStack(alignment: horizontalSizeClass == .regular ? .leading : .leading) {
            Text("Write a Review")
                .font(.title.weight(.semibold))

            Text("Reviews are very important on the App Store. You can also rate Overamped without writing a review.")

            Link(
                destination: URL(string: "https://itunes.apple.com/app/id1573901090?action=write-review&mt=8")!,
                label: {
                    Text("\(Image(systemName: "square.and.pencil")) Review Overamped")
                }
            )
                .buttonStyle(BorderedButtonStyle())

            Text("Having an issue? [Submit feedback instead](overamped:feedback).")
                .font(.footnote)
        }
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
}
