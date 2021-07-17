import Combine
import SwiftUI
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

    var footer: String? {
        switch self {
        case .websiteLoadedAMPVersion:
            return "Please describe the issue and – where possible – provide the URL of the Google search and the URL of the AMP page that loaded."
        case .other, .initial:
            return ""
        }
    }
}

struct FeedbackForm: View {
    @ObservedObject private var formAPI: FormAPI = FormAPI()

    @Binding
    private var openURL: String?

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

                    Section(
                        footer: contactReasonFooter
                    ) {
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

                    Section(header: Text("Message")) {
                        ZStack(alignment: .topLeading) {
                            if formAPI.formData.message.isEmpty {
                                Text("Message")
                                    .foregroundColor(Color(.placeholderText))
                                    .padding(.top, 8)
                            }
                            TextEditor(text: $formAPI.formData.message).padding(.leading, -3)
                        }

                        if let openURL = openURL {
                            Button("Append Open URL") {
                                formAPI.formData.message += openURL
                            }
                            Button("Copy Open URL") {
                                UIPasteboard.general.string = openURL
                            }
                        }
                    }
                }
                .navigationBarItems(
                    trailing: navigationBarButton
                )
            }
        }
        .navigationBarTitle("Submit Feedback")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var contactReasonFooter: some View {
        if let text = formAPI.formData.contactReason.footer {
            Text(text)
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

    init(openURL: Binding<String?> = .constant(nil)) {
        _openURL = openURL
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

    private var cancellables: Set<AnyCancellable> = []

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

}

private final class FormData: ObservableObject, Encodable, CustomReflectable {
    enum CodingKeys: CodingKey {
        case name
        case email
        case contactReason
        case message
        case source
    }

    @Published var name: String = ""
    @Published var email: String = ""
    @Published var contactReason: FeedbackReason = .initial
    @Published var message: String = ""

    var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "name": name,
                "email": email,
                "contactReason": contactReason,
                "message": message,
            ]
        )
    }

    var isValid: Bool {
        switch contactReason {
        case .websiteLoadedAMPVersion, .other:
            return !message.isEmpty
        case .initial:
            return false
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(contactReason.title, forKey: .contactReason)
        try container.encode(message, forKey: .message)
        try container.encode("app", forKey: .source)
    }
}

private struct FormResponse: Decodable {
    let status: Int
    let message: String?
}
