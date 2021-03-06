import Combine
import Persist
import SwiftUI
import OverampedCore
import os.log

enum FeedbackReason: Hashable, CaseIterable {
    case websiteLoadedAMPVersion
    case other
    case initial

    var title: String {
        switch self {
        case .websiteLoadedAMPVersion:
            return "Website loaded AMP version"
        case .other:
            return "Other"
        case .initial:
            return ""
        }
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
                    case .websiteLoadedAMPVersion = formAPI.formData.contactReason,
                    let ignoredHostname = formAPI.formData.ignoredHostnames.first(where: { formAPI.formData.websiteURL.contains($0) })
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
                        TextField("Name (optional)", text: $formAPI.formData.name)
                            .textContentType(.name)

                        TextField("Email (optional)", text: $formAPI.formData.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                    }

                    Section() {
                        Picker(
                            selection: $formAPI.formData.contactReason,
                            label: Text("Contact Reason")
                        ) {
                            ForEach(FeedbackReason.allCases, id: \.hashValue) { reason in
                                if reason != .initial {
                                    Text(reason.title)
                                        .tag(reason)
                                }
                            }
                        }
                    }

                    switch formAPI.formData.contactReason {
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
                            TextField("Search URL", text: $formAPI.formData.searchURL)
                                .textContentType(.URL)
                                .keyboardType(.URL)
                            TextField("Website URL", text: $formAPI.formData.websiteURL)
                                .textContentType(.URL)
                                .keyboardType(.URL)
                        }
                    case .other, .initial:
                        EmptyView()
                    }

                    messageSection

                    Section(
                        header: Text("Debug Data")
                    ) {
                        if !formAPI.formData.ignoredHostnames.isEmpty {
                            Toggle("Send ignored websites", isOn: $formAPI.formData.includeIgnoredHostnames)
                        }

                        let debugDataString = (try? formAPI.formData.debugDataJSONString) ?? "Failed to encode"
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
                    formAPI.formData.websiteURL = url.absoluteString
                }

                formAPI.formData.permittedOrigins = permittedOrigins
            case .searchFeedback(let url, let permittedOrigins):
                if let url = url {
                    formAPI.formData.searchURL = url.absoluteString
                }

                formAPI.formData.permittedOrigins = permittedOrigins
            default:
                break
            }
        })
    }

    @ViewBuilder
    private var messageSection: some View {
        let isOptional = formAPI.formData.contactReason == .websiteLoadedAMPVersion

        Section(header: Text("Message")) {
            ZStack(alignment: .topLeading) {
                if formAPI.formData.message.isEmpty {
                    Text("Message\(isOptional ? " (optional)" : "")")
                        .foregroundColor(Color(.placeholderText))
                        .padding(.top, 8)
                }
                TextEditor(text: $formAPI.formData.message).padding(.leading, -3)
            }
        }
    }

    @ViewBuilder
    private var navigationBarButton: some View {
        switch formAPI.formState {
        case .idle, .error:
            Button("Submit") {
                formAPI.submit()
            }.disabled(!formAPI.formData.isValid)
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

private final class FormAPI: ObservableObject {
    enum FormState: Equatable {
        case idle
        case submitting
        case error(String)
        case success
    }

    @ObservedObject var formData: FormData = FormData()

    @Published private(set) var formState: FormState = .idle

    private var cancellables: Set<Combine.AnyCancellable> = []

    private let logger = Logger(subsystem: "net.yetii.Overamped", category: "FormAPI")

    init() {
        formData.objectWillChange.sink { self.objectWillChange.send() }.store(in: &cancellables)
    }

    func submit() {
        formState = .submitting

        do {
            let bodyEncoder = JSONEncoder()
            var request = URLRequest(url: URL(string: "https://contact.josephduffy.co.uk/overamped-feedback")!)
            request.httpMethod = "POST"
            request.httpBody = try bodyEncoder.encode(formData)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.attribution = .user

            logger.log("Submitting contact form \(String(describing: self.formData))")

            URLSession
                .shared
                .dataTaskPublisher(for: request)
                .map { data, response -> FormState in
                    self.logger.log("Received response \(response)")

                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(FormResponse.self, from: data)

                        self.logger.log("Received form response \(String(describing: response))")

                        if response.status == 200 {
                            return .success
                        } else {
                            self.logger.error("Response status was not 200: \(response.status)")

                            return .error(response.message ?? "Unknown response (\(response.status)). Please try again later")
                        }
                    } catch {
                        self.logger.error("Failed to decode response: \(String(describing: error))\n\(String(data: data, encoding: .utf8) ?? "<not utf8>")")

                        return .error("Unknown response. Please try again later")
                    }
                }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        self.logger.error("Failed to submit form \(String(describing: error))")
                        self.formState = .error(error.localizedDescription)
                    case .finished:
                        break
                    }
                }, receiveValue: { formState in
                    self.formState = formState
                })
                .store(in: &cancellables)
        } catch {
            formState = .error(error.localizedDescription)
        }
    }

    func reset() {
        formData = FormData()
        formState = .idle
    }
}

private final class FormData: ObservableObject, Encodable, CustomReflectable {
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

    @Published var name: String = ""
    @Published var email: String = ""
    @Published var contactReason: FeedbackReason = .initial
    @Published var message: String = ""
    @Published var searchURL: String = ""
    @Published var permittedOrigins: [String]?
    @Published var websiteURL: String = ""

    @Published
    var includeIgnoredHostnames: Bool = true

    @PersistStorage(persister: .ignoredHostnames)
    private(set) var ignoredHostnames: [String]

    var debugData: DebugData {
        DebugData(ignoredHostnames: includeIgnoredHostnames ? ignoredHostnames : nil, permittedOrigins: permittedOrigins)
    }

    var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "name": name,
                "email": email,
                "contactReason": contactReason,
                "message": message,
                "searchURL": searchURL,
                "websiteURL": websiteURL,
                "debugData": debugData,
            ]
        )
    }

    var isValid: Bool {
        switch contactReason {
        case .websiteLoadedAMPVersion:
            return !websiteURL.isEmpty && !searchURL.isEmpty
        case .other:
            return !message.isEmpty
        case .initial:
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

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(contactReason.title, forKey: .contactReason)
        try container.encode(message, forKey: .message)
        try container.encode(debugData, forKey: .debugData)
        try container.encode("app", forKey: .source)

        switch contactReason {
        case .websiteLoadedAMPVersion:
            try container.encode(searchURL, forKey: .searchURL)
            try container.encode(websiteURL, forKey: .websiteURL)
        case .other, .initial:
            break
        }
    }
}

private struct FormResponse: Decodable {
    let status: Int
    let message: String?
}
