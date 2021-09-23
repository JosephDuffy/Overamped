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
                            Text("Overamped is created by Joseph Duffy, an indie developer from the UK")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 4)
                    }

                }

                Button(action: {
                    displayedURL = DisplayedURL(url: URL(string: "https://josephduffy.co.uk/apps")!)
                }, label: {
                    HStack {
                        Label {
                            Text("View More Apps I've Made")
                                .foregroundColor(Color.primary)
                        } icon: {
                            Image("app.store.circle.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                        }

                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(Font.system(size: 14).weight(.semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                })

                Link(destination: URL(string: "https://twitter.com/Joe_Duffy")!) {
                    HStack {
                        Label {
                            Text("Follow @Joe_Duffy")
                                .foregroundColor(Color.primary)
                        } icon: {
                            Image("twitter")
                                .font(.title3)
                                .foregroundColor(.accentColor)
                        }

                        Spacer()
                        Image(systemName: "arrow.up.forward.app.fill")
                            .font(Font.system(size: 14).weight(.semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                }
            }

            Section("Overamped") {
                NavigationLink(
                    destination: InstallationInstructionsView(hasAlreadyInstalled: true),
                    isActive: $showInstallationInstructions
                ) {
                    Label {
                        Text("Installation Instructions")
                    } icon: {
                        Image(systemName: "puzzlepiece.fill")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    }
                }

                NavigationLink(
                    destination: FAQView(),
                    isActive: $showFAQ
                ) {
                    Label {
                        Text("FAQ")
                    } icon: {
                        Image(systemName: "questionmark.circle")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    }
                }

                Button(action: {
                    displayedURL = DisplayedURL(url: URL(string: "https://github.com/JosephDuffy/Overamped")!)
                }, label: {
                    Label {
                        Text("Source Code")
                    } icon: {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    }
                })

                Button(action: {
                    displayedURL = DisplayedURL(url: URL(string: "https://overamped.app/privacy")!)
                }, label: {
                    HStack {
                        Label {
                            Text("Privacy Policy")
                                .foregroundColor(Color.primary)
                        } icon: {
                            Image(systemName: "eye.slash.fill")
                                .font(.title3)
                                .foregroundColor(.accentColor)
                        }

                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(Font.system(size: 14).weight(.semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                })

                Link(destination: URL(string: "https://twitter.com/OverampedApp")!) {
                    HStack {
                        Label {
                            Text("Follow @OverampedApp")
                                .foregroundColor(Color.primary)
                        } icon: {
                            Image("twitter")
                                .font(.title3)
                                .foregroundColor(.accentColor)
                        }

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
                    Label {
                        Text("Acknowledgements")
                    } icon: {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    }
                }
            }

            Section(
                footer: Text("© Yetii Ltd. 2021. Overamped \(Bundle.main.appVersion) (\(Bundle.main.appBuild))")
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            ) {}
        }
        .background(Color(.systemGroupedBackground))
        .sheet(item: $displayedURL, onDismiss: { displayedURL = nil }) { displayedURL in
            SafariView(url: displayedURL.url) {
                self.displayedURL = nil
            }
        }
        .onOpenURL(perform: { url in
            guard let deepLink = DeepLink(url: url) else { return }

            switch deepLink {
            case .installationInstructions:
                showInstallationInstructions = true
            default:
                break
            }
        })
        .navigationTitle("About")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutView()
        }
        .previewLayout(.sizeThatFits)
    }
}

extension HorizontalAlignment {
    /// A custom alignment for image titles.
    private struct ImageTitleAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            // Default to bottom alignment if no guides are set.
            context[HorizontalAlignment.leading]
        }
    }


    /// A guide for aligning titles.
    static let imageTitleAlignmentGuide = VerticalAlignment(
        ImageTitleAlignment.self
    )
}
