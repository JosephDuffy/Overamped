import Combine
import Persist
import SwiftUI
import OverampedCore
import os.log

enum FeedbackReason: Hashable, CaseIterable, Encodable {
    case websiteLoadedAMPVersion
    case other

    var title: String {
        switch self {
        case .websiteLoadedAMPVersion:
            return "Website loaded AMP version"
        case .other:
            return "Other"
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(title)
    }
}

struct FeedbackForm: View {
    @StateObject private var formAPI: FormAPI = FormAPI()

    var body: some View {
        VStack(spacing: 0) {
            if case .success = formAPI.formState {
                HStack {
                    Spacer()
                    Text("Message Submitted")
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemGreen))

                Spacer()
            } else {
                if case .error(let error) = formAPI.formState {
                    Divider()

                    HStack {
                        Spacer()
                        Text(error)
                            .foregroundColor(Color(.systemRed))
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemFill))
                }

                if
                    case .websiteLoadedAMPVersion = formAPI.formBuilder.formData.contactReason,
                    let ignoredHostname = formAPI.formBuilder.ignoredHostnames.first(where: { formAPI.formBuilder.formData.websiteURL.contains($0) })
                {
                    Divider()

                    HStack {
                        Spacer()
                        Text("\(ignoredHostname) is currently ignored. Try opening the website and enabling Overamped.")
                            .foregroundColor(Color(.systemRed))
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemFill))
                }

                Form {
                    Section(
                        footer: Text("Submit this form to send me feedback about Overamped. I am a solo indie app developer so please allow a couple of days before your message is addressed.")
                            .font(.body)
                            .padding(.horizontal, -16)
                            .padding(.top, -64)
                            .foregroundColor(Color.primary)
                    ) {}

                    Section(
                        header: Text("Contact Details"),
                        footer: Text("Please provide contact details if you would like me to follow up with you, or if you're willing to provide help debug any issues you report.")
                    ) {
                        TextField("Name (optional)", text: $formAPI.formBuilder.formData.name)
                            .textContentType(.name)

                        TextField("Email (optional)", text: $formAPI.formBuilder.formData.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                    }

                    Section() {
                        HStack {
                            Text("Contact Reason")
                            Spacer()
                            Menu {
                                ForEach(FeedbackReason.allCases, id: \.hashValue) { reason in
                                    if reason == formAPI.formBuilder.formData.contactReason {
                                        Toggle(reason.title, isOn: .constant(true))
                                    } else {
                                        Button(reason.title) {
                                            formAPI.formBuilder.formData.contactReason = reason
                                        }
                                    }
                                }
                            } label: {
                                Label {
                                    if let contactReason = formAPI.formBuilder.formData.contactReason {
                                        Text(contactReason.title)
                                    } else {
                                        Text("Select Reason")
                                    }
                                } icon: {
                                    Image(systemName: "chevron.up.chevron.down")
                                }
                                .labelStyle(MenuButtonLabelStyle())
                            }
                        }
                    }

                    switch formAPI.formBuilder.formData.contactReason {
                    case .websiteLoadedAMPVersion:
                        Section (
                            footer: Text("If no AMP links are being redirected the Overamped Install Checker can help verify that the Safari Extension is enabled and configured correctly.")
                        ) {
                            Link(destination: URL(string: "https://overamped.app/install-checker")!) {
                                HStack {
                                    Text("Install Checker")
                                        .foregroundColor(.accentColor)
                                    Spacer()
                                    Image(systemName: "arrow.up.forward.app.fill")
                                        .font(Font.system(size: 14).weight(.semibold))
                                        .foregroundColor(Color(.tertiaryLabel))
                                }
                            }
                        }
                        Section(
                            header: Text("Problem Links")
                        ) {
                            TextField("Search URL", text: $formAPI.formBuilder.formData.searchURL)
                                .textContentType(.URL)
                                .keyboardType(.URL)
                            TextField("Website URL", text: $formAPI.formBuilder.formData.websiteURL)
                                .textContentType(.URL)
                                .keyboardType(.URL)
                        }
                    case .other, nil:
                        EmptyView()
                    }

                    messageSection

                    Section(
                        header: Text("Debug Data")
                    ) {
                        if !formAPI.formBuilder.ignoredHostnames.isEmpty {
                            Toggle("Send ignored websites", isOn: $formAPI.formBuilder.includeIgnoredHostnames)
                        }

                        let debugDataString = (try? formAPI.formBuilder.debugDataJSONString) ?? "Failed to encode"
                        Text(debugDataString)
                    }
                }
                .navigationBarItems(
                    trailing: navigationBarButton
                )
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitle("Submit Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            switch formAPI.formState {
            case .success:
                formAPI.reset()
            case .idle, .error, .submitting:
                break
            }
        }
        .onOpenURL(perform: { url in
            Logger(subsystem: "net.yetii.Overamped", category: "Feedback Form")
                .log("Opened via URL \(url.absoluteString)")

            guard let deepLink = DeepLink(url: url) else { return }

            switch deepLink {
            case .websiteFeedback(let url, let permittedOrigins):
                if let url = url {
                    formAPI.formBuilder.formData.websiteURL = url.absoluteString
                }

                formAPI.formBuilder.formData.permittedOrigins = permittedOrigins
            case .searchFeedback(let url, let permittedOrigins):
                if let url = url {
                    formAPI.formBuilder.formData.searchURL = url.absoluteString
                }

                formAPI.formBuilder.formData.permittedOrigins = permittedOrigins
            default:
                break
            }
        })
    }

    @ViewBuilder
    private var messageSection: some View {
        let isOptional = formAPI.formBuilder.formData.contactReason == .websiteLoadedAMPVersion

        Section(header: Text("Message")) {
            ZStack(alignment: .topLeading) {
                if formAPI.formBuilder.formData.message.isEmpty {
                    Text("Message\(isOptional ? " (optional)" : "")")
                        .foregroundColor(Color(.placeholderText))
                        .padding(.top, 8)
                }
                TextEditor(text: $formAPI.formBuilder.formData.message).padding(.leading, -3)
            }
        }
    }

    @ViewBuilder
    private var navigationBarButton: some View {
        switch formAPI.formState {
        case .idle, .error:
            Button("Submit") {
                formAPI.submit()
            }.disabled(!formAPI.formBuilder.isValid)
        case .submitting:
            ProgressView()
        case .success:
            Button("Submit", action: {}).disabled(true)
        }
    }
}

struct FeedbackForm_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackForm()
    }
}

@MainActor
private final class FormAPI: ObservableObject {
    enum FormState: Equatable {
        case idle
        case submitting
        case error(String)
        case success
    }

    @ObservedObject var formBuilder: FormBuilder = FormBuilder()

    @Published private(set) var formState: FormState = .idle

    private var cancellables: Set<Combine.AnyCancellable> = []

    private let logger = Logger(subsystem: "net.yetii.Overamped", category: "FormAPI")

    init() {
        formBuilder.objectWillChange.sink { self.objectWillChange.send() }.store(in: &cancellables)
    }

    func submit() {
        formState = .submitting

        do {
            let bodyEncoder = JSONEncoder()
            var request = URLRequest(url: URL(string: "https://contact.josephduffy.co.uk/overamped-feedback")!)
            request.httpMethod = "POST"
            request.httpBody = try bodyEncoder.encode(formBuilder.formData)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.attribution = .user

            logger.log("Submitting contact form \(String(describing: self.formBuilder.formData))")

            Task {
                let formState: FormState

                defer {
                    self.formState = formState
                }

                do {
                    let (data, response) = try await URLSession.shared.data(for: request)

                    do {
                        logger.log("Received response \(response)")

                        let decoder = JSONDecoder()
                        let response = try decoder.decode(FormResponse.self, from: data)

                        logger.log("Received form response \(String(describing: response))")

                        if response.status == 200 {
                            formState = .success
                        } else {
                            logger.error("Response status was not 200: \(response.status)")

                            formState = .error(response.message ?? "Unknown response (\(response.status)). Please try again later")
                        }
                    } catch {
                        logger.error("Failed to decode response: \(String(describing: error))\n\(String(data: data, encoding: .utf8) ?? "<not utf8>")")

                        formState = .error("Unknown response. Please try again later")
                    }
                } catch {
                    self.logger.error("Failed to submit form \(String(describing: error))")
                    formState = .error(error.localizedDescription)
                    return
                }
            }
        } catch {
            formState = .error(error.localizedDescription)
        }
    }

    func reset() {
        formBuilder = FormBuilder()
        formState = .idle
    }
}

private struct FormData: Encodable {
    var name: String = ""
    var email: String = ""
    var contactReason: FeedbackReason?
    var message: String = ""
    var searchURL: String = ""
    var permittedOrigins: [String]?
    var websiteURL: String = ""
    private let source = "app"
}

@MainActor
//@dynamicMemberLookup
private final class FormBuilder: ObservableObject {
    enum CodingKeys: CodingKey {
        case name
        case email
        case contactReason
        case message
        case searchURL
        case websiteURL
        case debugData
        case source
    }

    struct DebugData: Codable {
        let versionString: String?
        let buildNumber: String?
        let osVersion: String
        let ignoredHostnames: [String]?
        let permittedOrigins: [String]?

        init(ignoredHostnames: [String]?, permittedOrigins: [String]?, bundle: Bundle = .main) {
            self.ignoredHostnames = ignoredHostnames
            self.permittedOrigins = permittedOrigins
            versionString = bundle.infoDictionary?["CFBundleShortVersionString"] as? String
            buildNumber = bundle.infoDictionary?["CFBundleVersion"] as? String
            osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        }
    }

    @Published var formData = FormData()

//    subscript<Value>(dynamicMember keyPath: KeyPath<FormData, Value>) -> Value {
//        formData[keyPath: keyPath]
//    }

//    subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<FormData, Value>) -> Value {
//        get {
//            formData[keyPath: keyPath]
//        }
//        set {
//            formData[keyPath: keyPath] = newValue
//        }
//    }
//
//    subscript<Value>(dynamicMember keyPath: WritableKeyPath<FormData, Published<Value>.Publisher>) -> Published<Value>.Publisher {
//        get {
//            formData[keyPath: keyPath]
//        }
//        set {
//            formData[keyPath: keyPath] = newValue
//        }
//    }

    @Published
    var includeIgnoredHostnames: Bool = true

    @PersistStorage(persister: .ignoredHostnames)
    private(set) var ignoredHostnames: [String]

    var debugData: DebugData {
        DebugData(ignoredHostnames: includeIgnoredHostnames ? ignoredHostnames : nil, permittedOrigins: formData.permittedOrigins)
    }

    var isValid: Bool {
        switch formData.contactReason {
        case .websiteLoadedAMPVersion:
            return !formData.websiteURL.isEmpty && !formData.searchURL.isEmpty
        case .other:
            return !formData.message.isEmpty
        case nil:
            return false
        }
    }

    var debugDataJSONString: String {
        get throws {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let jsonData = try encoder.encode(debugData)
            return String(data: jsonData, encoding: .utf8) ?? "<invalid UTF8>"
        }
    }

    private var cancellables: Set<Combine.AnyCancellable> = []

    init() {
        _ignoredHostnames.persister.publisher.sink { _ in self.objectWillChange.send() }.store(in: &cancellables)
    }
}

private struct FormResponse: Decodable {
    let status: Int
    let message: String?
}

private struct MenuButtonLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 4) {
            configuration.title
            configuration.icon
        }
        .foregroundStyle(Color(uiColor: .secondaryLabel))
        .imageScale(.small)
    }
}
