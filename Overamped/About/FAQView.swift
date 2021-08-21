import SwiftUI

struct FAQView: View {
    private let questions: [Question] = Self.allQuestions

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(questions) { question in
                    Text(question.question)
                        .font(.title)
                    Text(question.answer)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .navigationTitle("FAQ")
    }
}

struct FAQView_Previews: PreviewProvider {
    static var previews: some View {
        FAQView()
    }
}

private struct Question: Hashable, Identifiable {
    var id: String {
        question
    }

    let question: String
    let answer: AttributedString
}

extension FAQView {
    fileprivate static var allQuestions: [Question] {
        [
            Question(
                question: "Does Overamped change the search results I see?",
                answer: "No. The removal of AMP is done entirely on-device, and no results are ever removed, reordered, replaced, or otherwise altered in any way, other than to link to the canonical non-AMP version."
            ),
            Question(
                question: "Will I always see the full original version of websites?",
                answer: """
                Yes, when access to “Other Websites” been granted.

                If access to “Other Websites” has not been granted Overamped will try to calculate the best URL to redirect to, but it may not always be the original webpage and for some websites will redirect to a page that cannot be found. To learn more read “Why does Overamped work best with access to “Other Websites”?”.
                """
            ),
            Question(
                question: "Why does Overamped work best with access to “Other Websites”?",
                answer: try! AttributedString(
                    markdown: """
                Google search results do not include the canonical (non-AMP) URL in the search results, which makes is impossible for Overamped to know the correct URL to redirect to. Without access to “Other Websites” Overamped will make a best guess to “de-AMP” the URL, but this will not always work.

                This is because not all website use URLs that can be “de-AMP” using a single algorithm. For example for an abc.net.au article Google provides the URL `https://amp.abc.net.au/article/100303036` but removing the `amp.` subdomain will yield `https://abc.net.au/article/100303036`, a URL that cannot be found (also known as a 404 error).

                When access to “Other Websites” is provided Overamped will skip the Google AMP cache but will still load the AMP version of the search result. As soon as the AMP version starts to load it will read the real canonical version of webpage and redirect to it.
                """,
                    options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
                )
            ),
            Question(
                question: "A specific website isn't redirecting correctly, can I provide access to only that website to fix the redirection?",
                answer: """
                Yes, providing access to specific websites will also fix incorrect redirects. To provide access to a specific website first visit the website, then open Overamped on that page and grant access to the website.

                Note that any new permissions will not be applied until pages that Overamped is active on are reloaded.
                """
            ),
        ]
    }
}
