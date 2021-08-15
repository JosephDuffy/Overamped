import SwiftUI
import WebKit

struct AboutView: View {
    @SceneStorage("AboutView.showInstallationInstructions")
    private var showInstallationInstructions = false

    @SceneStorage("AboutView.showAcknowledgements")
    private var showAcknowledgements = false

    @SceneStorage("AboutView.showFAQ")
    private var showFAQ = false

    @State
    private var displayedURL: DisplayedURL?

    private struct DisplayedURL: Identifiable {
        var id: String {
            url.absoluteString
        }

        let url: URL
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    HStack {
                        Image("LargeIcon")
                            .resizable()
                            .frame(width: 64, height: 64)
                        VStack(alignment: .leading) {
                            Text("Overamped")
                                .font(.headline)
                            Text("by Joseph Duffy")
                                .font(.subheadline)
                        }
                    }
                    Text("Overamped is created by Joseph Duffy, an indie developer from the UK.")
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button(action: {
                    displayedURL = DisplayedURL(url: URL(string: "https://josephduffy.co.uk/apps")!)
                }, label: {
                    HStack {
                        Image(systemName: "app.fill")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                        Text("View More Apps I've Made")
                            .foregroundColor(Color.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(Font.system(size: 14).weight(.semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                })

                Link(destination: URL(string: "https://twitter.com/Joe_Duffy")!) {
                    HStack {
                        Image("twitter")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                        Text("Follow Me on Twitter")
                            .foregroundColor(Color.primary)
                        Spacer()
                        Image(systemName: "arrow.up.forward.app.fill")
                            .font(Font.system(size: 14).weight(.semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                }
            }

            Section("Overamped") {
                NavigationLink(
                    destination: InstallationInstructionsView(),
                    isActive: $showInstallationInstructions
                ) {
                    Image(systemName: "puzzlepiece.fill")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                    Text("Installation Instructions")
                }

                NavigationLink(
                    destination: FAQView(),
                    isActive: $showFAQ
                ) {
                    Image(systemName: "questionmark.circle")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                    Text("FAQ")
                }

                Button(action: {
                    displayedURL = DisplayedURL(url: URL(string: "https://overamped.app/privacy")!)
                }, label: {
                    HStack {
                        Image(systemName: "eye.slash.fill")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                        Text("Privacy Policy")
                            .foregroundColor(Color.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(Font.system(size: 14).weight(.semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                })

                Link(destination: URL(string: "https://twitter.com/OverampedApp")!) {
                    HStack {
                        Image("twitter")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                        Text("Follow @OverampedApp on Twitter")
                            .foregroundColor(Color.primary)
                        Spacer()
                        Image(systemName: "arrow.up.forward.app.fill")
                            .font(Font.system(size: 14).weight(.semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                }

                NavigationLink(
                    destination: Acknowledgements(),
                    isActive: $showAcknowledgements
                ) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                    Text("Acknowledgements")
                }
            }

            Section(
                footer: Text("© Yetii Ltd. 2021. Overamped \(Bundle.main.appVersion) (\(Bundle.main.appBuild))")
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            ) {}
        }
        .sheet(item: $displayedURL, onDismiss: { displayedURL = nil }) { displayedURL in
            SafariView(url: displayedURL.url) {
                self.displayedURL = nil
            }
        }
        .navigationTitle("About")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutView()
        }
    }
}
