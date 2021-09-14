import Combine
import Foundation
import UIKit

public final class FAQLoader: ObservableObject {
    @Published
    @MainActor
    private(set) var questions: [Question] = []

    public init(bundle: Bundle = .main) {
        Task {
            await loadQuestionsInBundle(bundle)
            await loadLatestQuestions()
        }
    }

    @MainActor
    public func questionWithId(_ id: String) -> Question? {
        questions.first(where: { $0.id == id })
    }

    private func loadQuestionsInBundle(_ bundle: Bundle) async {
        do {
            guard let bundledDataAsset = NSDataAsset(name: "FAQ.json", bundle: bundle) else {
                print("No FAQ json in bundle")
                return
            }
            let jsonData = bundledDataAsset.data
            let decoder = JSONDecoder()
            let questions = try decoder.decode([Question].self, from: jsonData).filter { $0.platforms.contains(.app) }
            await MainActor.run {
                self.questions = questions
                print("JSON Data loaded from bundle")
            }
        } catch {
            print("Failed to load questions from bundle", error)
        }
    }

    private func loadLatestQuestions() async {
        do {
            let url = URL(string: "https://overamped.app/api/faq")!
            let (jsonData, _) = try await URLSession.shared.data(from: url, delegate: nil)
            let decoder = JSONDecoder()
            let questions = try decoder.decode([Question].self, from: jsonData).filter { $0.platforms.contains(.app) }
            await MainActor.run {
                self.questions = questions
                print("JSON Data loaded from network")
            }
        } catch {
            print("Failed to load JSON data from network", error)
        }
    }
}
