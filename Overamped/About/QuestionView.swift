import SwiftUI

struct QuestionView: View {
    private let question: Question

    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question.title)
                .font(.title2.bold())
            ForEach(question.answer, id: \.self) { answer in
                Text(answer)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        }
        .padding(.bottom)
    }

    init(question: Question) {
        self.question = question
    }
}
