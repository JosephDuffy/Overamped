import Combine
import Foundation
import os.log
import UIKit

public final class FAQLoader: ObservableObject {
    @Published
    @MainActor
    private(set) var questions: [Question] = []

    private let logger: Logger

    public init(bundle: Bundle = .main) {
        logger = Logger(subsystem: "net.yetii.Overamped", category: "FAQ Loader")
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
                logger.debug("Loaded questions from bundle \(questions.map(\.title))")
                self.questions = questions
            }
        } catch {
            logger.debug("Failed to load questions from bundle: \(error.localizedDescription)")
        }
    }

    private func loadLatestQuestions() async {
        do {
            let url = URL(string: "https://overamped.app/api/faq")!
            let (jsonData, _) = try await URLSession.shared.data(from: url, delegate: nil)
            let decoder = JSONDecoder()
            let questions = try decoder.decode([Question].self, from: jsonData).filter { $0.platforms.contains(.app) }
            await MainActor.run {
                logger.debug("Loaded questions from network \(questions.map(\.title))")
                self.questions = questions
            }
        } catch {
            logger.debug("Failed to load questions from network: \(error.localizedDescription)")
        }
    }
}
