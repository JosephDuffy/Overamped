import Combine
import SwiftUI
import os.log

public struct SurveyView: View {
    @StateObject
    private var store: SurveyPricesProvider = SurveyPricesProvider()

    @StateObject
    private var surveyAPI: SurveyAPI = SurveyAPI()

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                switch surveyAPI.formState {
                case .idle:
                    currentQuestions
                case .error(let error):
                    VStack {
                        Text(error)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemRed))
                    currentQuestions
                case .submitting:
                    ProgressView("Submitting Answers...")
                    currentQuestions
                        .disabled(true)
                case .success:
                    VStack {
                        Text("Thank you for completing the survey!")
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGreen))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Pricing Survey")
    }

    @ViewBuilder
    private var currentQuestions: some View {
        VStack(alignment: .leading, spacing: 16) {
            let firstQuestion = "How much would you be willing to pay for Overamped?"

            if let wouldYouPayForOveramped = surveyAPI.answers.wouldYouPayForOveramped {
                Text("\(firstQuestion)\n**\(wouldYouPayForOveramped.description)**")

                let wouldPay = wouldYouPayForOveramped != .no
                let secondQuestion = "Would you\(wouldPay ? " also" : "") consider contributing to a tip jar?"

                if let wouldYouContributeToATipJar = surveyAPI.answers.wouldYouContributeToATipJar {
                    Text("\(secondQuestion)\n**\(wouldYouContributeToATipJar.description)**")

                    let enableSubmitButton: Bool = {
                        if surveyAPI.answers.wouldYouContributeToATipJar == nil || surveyAPI.answers.wouldYouPayForOveramped == nil {
                            return false
                        }

                        switch surveyAPI.formState {
                        case .idle, .error:
                            return true
                        case .submitting, .success:
                            return false
                        }
                    }()

                    VStack(spacing: 16) {
                        Button("Submit Answers") {
                            surveyAPI.submit()
                        }
                        .disabled(!enableSubmitButton)
                    }
                } else {
                    Text(secondQuestion)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.title)

                    VStack(spacing: 16) {
                        ForEach(SurveyAnswers.WouldYouContributeToATipJar.allCases, id: \.self) { answer in
                            Button(answer.description) {
                                surveyAPI.answers.wouldYouContributeToATipJar = answer
                            }
                        }
                    }
                }
            } else {
                Text(firstQuestion)
                    .font(.title)

                switch store.state {
                case .loadingProducts:
                    ProgressView("Loading Options...")
                        .frame(maxWidth: .infinity)
                case .error(let error):
                    Text("Failed to load options: \(error.localizedDescription)")
                case .idle:
                    VStack(spacing: 16) {
                        Button("I would not pay for Overamped") {
                            answerQuestion(SurveyAnswers.WouldYouPayForOveramped.no)
                        }

                        ForEach(store.products) { product in
                            Button(product.displayPrice) {
                                answerQuestion(.yes(product))
                            }
                        }

                        store.products.sorted(by: { $0.price < $1.price }).last.flatMap { product in
                            Button("More than \(product.displayPrice)") {
                                answerQuestion(.moreThan(product))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }

    private func answerQuestion(_ answer: SurveyAnswers.WouldYouPayForOveramped) {
        surveyAPI.answers.wouldYouPayForOveramped = answer
    }

    private func answerQuestion(_ answer: SurveyAnswers.WouldYouContributeToATipJar) {
        surveyAPI.answers.wouldYouContributeToATipJar = answer
    }
}

struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyView()
    }
}

private final class SurveyAPI: ObservableObject {
    enum FormState: Equatable {
        case idle
        case submitting
        case error(String)
        case success
    }

    @ObservedObject var answers: SurveyAnswers = .init()

    @Published private(set) var formState: FormState = .idle

    private var cancellables: Set<Combine.AnyCancellable> = []

    private let logger = Logger(subsystem: "net.yetii.Overamped", category: "SurveyAPI")

    init() {
        answers.objectWillChange.sink { self.objectWillChange.send() }.store(in: &cancellables)
    }

    func submit() {
        formState = .submitting

        do {
            let bodyEncoder = JSONEncoder()
            var request = URLRequest(url: URL(string: "https://contact.josephduffy.co.uk/overamped-pricing-survey")!)
            request.httpMethod = "POST"
            request.httpBody = try bodyEncoder.encode(answers)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            logger.log("Submitting pricing survey form \(String(describing: self.answers))")

            URLSession
                .shared
                .dataTaskPublisher(for: request)
                .map { data, response -> FormState in
                    self.logger.log("Received response \(response)")

                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(SurveyResponse.self, from: data)

                        self.logger.log("Received form response \(String(describing: response))")

                        if response.status == 200 {
                            UserDefaults.standard.set(true, forKey: "HasSubmittedPricingSurvey")
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

private struct SurveyResponse: Decodable {
    let status: Int
    let message: String?
}
