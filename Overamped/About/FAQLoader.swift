import Combine
import Foundation

public final class FAQLoader: ObservableObject {
    @Published
    private(set) var questions: [Question] = []

    public init(bundle: Bundle = .main) {
        loadQuestionsInBundle(bundle)

        Task {
            await loadLatestQuestions()
        }
    }

    public func questionWithId(_ id: String) -> Question? {
        questions.first(where: { $0.id == id })
    }

    private func loadQuestionsInBundle(_ bundle: Bundle) {
        do {
            guard let bundledJSON = bundle.url(forResource: "faq", withExtension: "json") else { return }
            guard let jsonData = FileManager.default.contents(atPath: bundledJSON.path) else { return }
            let decoder = JSONDecoder()
            questions = try decoder.decode([Question].self, from: jsonData).filter { $0.platforms.contains(.app) }
        } catch {
            print("Failed to load questions from bundle", error)
        }
    }

    private func loadLatestQuestions() async {
        do {
            let url = URL(string: "https://overamped.app/api/faq")!
            for try await response in URLSession.shared.dataTaskPublisher(for: url).values {
                let jsonData = response.data
                let decoder = JSONDecoder()
                questions = try decoder.decode([Question].self, from: jsonData).filter { $0.platforms.contains(.app) }
            }
            print("JSON Data loaded from network")
        } catch {
            print("Failed to load JSON data from network", error)
        }
    }
}
