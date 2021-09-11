import SwiftUI

struct FAQView: View {
    @EnvironmentObject
    private var faqLoader: FAQLoader

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(faqLoader.questions, id: \.title) { question in
                        QuestionView(question: question)
                            .id(question.id)
                    }
                }
                .padding(.horizontal)
                .environment(\.openURL, OpenURLAction { url in
                    if let questionId = url.fragment, url.absoluteString == "#\(questionId)" {
                        withAnimation {
                            scrollView.scrollTo(questionId, anchor: .top)
                        }

                        return .handled
                    }
                    return .systemAction
                })
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("FAQ")
    }
}

struct FAQView_Previews: PreviewProvider {
    static var previews: some View {
        FAQView()
            .previewDevice("iPhone SE (2nd Generation)")
    }
}
