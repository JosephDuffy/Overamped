import Combine
import Foundation
import os.log
import UIKit

public final class FAQLoader: ObservableObject {
    @Published
    @MainActor
    public private(set) var questions: [Question] = []

    private let logger: Logger

    public init() {
        logger = Logger(subsystem: "net.yetii.Overamped", category: "FAQ Loader")
    }

    @MainActor
    public func questionWithId(_ id: String) -> Question? {
        questions.first(where: { $0.id == id })
    }

    public func loadQuestions() async {
        await loadQuestionsInBundle(.main)
        await loadLatestQuestions(session: .shared)
    }

    public func loadQuestions(bundle: Bundle, session: URLSession) async {
        await loadQuestionsInBundle(bundle)
        await loadLatestQuestions(session: session)
    }

    public func loadQuestions(bundle: Bundle = .main) async {
        await loadQuestionsInBundle(bundle)
        await loadLatestQuestions(session: .shared)
    }

    public func loadQuestions(session: URLSession = .shared) async {
        await loadQuestionsInBundle(.main)
        await loadLatestQuestions(session: session)
    }

    public func loadQuestionsInBundle(_ bundle: Bundle) async {
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

    public func loadLatestQuestions(session: URLSession) async {
        do {
            let url = URL(string: "https://overamped.app/api/faq")!
            let (jsonData, _) = try await session.data(from: url, delegate: nil)
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
