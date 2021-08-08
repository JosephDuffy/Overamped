import SwiftUI

struct AboutView: View {
    @SceneStorage("AboutView.showInstallationInstructions")
    private var showInstallationInstructions = false
    @SceneStorage("AboutView.showAcknowledgements")
    private var showAcknowledgements = false
    @State private var showPrivacyPolicy = false
    @State private var showMoreApps = false

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
                    showMoreApps = true
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
                    .sheet(isPresented: $showMoreApps) {
                        SafariView(url: URL(string: "https://josephduffy.co.uk/apps")!) {
                            showMoreApps = false
                        }
                    }

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

                Button(action: {
                    showPrivacyPolicy = true
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
                    .sheet(isPresented: $showPrivacyPolicy) {
                        SafariView(url: URL(string: "https://overamped.app/privacy")!) {
                            showPrivacyPolicy = false
                        }
                    }

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
