import SwiftUI

struct InstallationInstructionsView: View {
    @State
    private var questionToDisplay: Question?

    @EnvironmentObject
    private var faqLoader: FAQLoader

    private let hasAlreadyInstalled: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Spacer()
                    Image("LargeIcon")
                    Spacer()
                }

                Text("The Overamped extension can be enabled from the Settings app.")

                Group {
                    Text("Start by opening Settings and scroll down to Safari:")

                    HStack {
                        Image("SafariTableIcon")
                            .resizable()
                            .frame(width: 29, height: 29)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray, lineWidth: 1 / UIScreen.main.nativeScale)
                            )
                        Text("Overamped")
                        Spacer()

                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(Font.system(size: 14).weight(.semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .frame(minHeight: 44)
                    .padding(.horizontal, 16)
                    .background(
                        Color(.secondarySystemGroupedBackground)
                    )
                }

                Group {
                    Text("Choose “Extensions”:")

                    HStack {
                        Text("Extensions")
                        Spacer()

                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(Font.system(size: 14).weight(.semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .frame(minHeight: 44)
                    .padding(.horizontal, 16)
                    .background(
                        Color(.secondarySystemGroupedBackground)
                    )
                }

                Group {
                    Text("Tap “Overamped”:")

                    HStack {
                        Image("LargeIcon")
                            .resizable()
                            .frame(width: 29, height: 29)
                        Text("Overamped")

                        Spacer()

                        Text("Off")
                            .foregroundColor(Color(.secondaryLabel))
                        Image(systemName: "chevron.right")
                            .font(Font.system(size: 14).weight(.semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .frame(minHeight: 44)
                    .padding(.horizontal, 16)
                    .background(
                        Color(.secondarySystemGroupedBackground)
                    )
                }

                Group {
                    Text("Turn “Overamped” on:")

                    HStack {
                        Image("LargeIcon")
                            .resizable()
                            .frame(width: 29, height: 29)
                        Text("Overamped")
                        Spacer()
                        Toggle(isOn: .constant(true), label: {})
                            .allowsHitTesting(false)
                    }
                    .frame(minHeight: 44)
                    .padding(.horizontal, 16)
                    .background(
                        Color(.secondarySystemGroupedBackground)
                    )

                    Text("Scroll down and select “Other Websites”:")

                    HStack {
                        Text("Other Websites")

                        Spacer()

                        Text("Ask")
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    .frame(minHeight: 44)
                    .padding(.horizontal, 16)
                    .background(
                        Color(.secondarySystemGroupedBackground)
                    )
                }

                Group {
                    Text("Finally choose “Allow”:")

                    VStack(alignment: .leading) {
                        HStack {
                            Text("Allow")

                            Spacer()

                            Image(systemName: "checkmark")
                                .font(.body.bold())
                                .foregroundColor(Color(.systemBlue))
                        }
                        .frame(minHeight: 44)
                        .padding(.horizontal, 16)
                        .background(
                            Color(.secondarySystemGroupedBackground)
                        )

                        if let whyOtherWebsitesQuestion = faqLoader.questionWithId("why-other-websites-permission") {
                            Button {
                                questionToDisplay = whyOtherWebsitesQuestion
                            } label: {
                                Text("Why grant access to “Other Websites”?")
                                    .font(.footnote)
                            }
                        }
                    }
                }

                Text("With this setup you should never see an AMP or Yandex Turbo page again!")

                if !hasAlreadyInstalled {
                    Text("Open a page in Safari with the Overamped extension activated to automatically unlock the rest of the app, or [unlock the app now](overamped://unlock).")
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Installation Instructions")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $questionToDisplay, onDismiss: { questionToDisplay = nil }) { questionToDisplay in
            NavigationView {
                ScrollView {
                    QuestionView(question: questionToDisplay)
                        .padding(.horizontal)
                        .toolbar {
                            Button(
                                action: {
                                    self.questionToDisplay = nil
                                },
                                label: {
                                    Text("Done")
                                }
                            )
                        }
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }

    init(hasAlreadyInstalled: Bool) {
        self.hasAlreadyInstalled = hasAlreadyInstalled
    }
}

struct InstallationInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstallationInstructionsView(hasAlreadyInstalled: false)
            .previewLayout(.sizeThatFits)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
