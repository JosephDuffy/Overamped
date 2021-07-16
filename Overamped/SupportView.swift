import SwiftUI

struct SupportView: View {
    @State private var showRecurringSubscriptions = false

    @State private var showShareSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("""
                    Overamped is developed by a single indie developer. If you're able to provide any extra support it is greatly appreciated.
                    """)

                Text("Share")
                    .font(.title)

                Text("The easiest way to support Overamped is to help spread the word.")

                Button("Share Overamped") {
                    showShareSheet = true
                }

                Group {
                    Text("Tip Jar")
                        .font(.title)

                    Text("Overamped requires ongoing maintenance to keep up-to-date with changes to iOS and Google. Any extra financial support will help with this tremendously.")

                    Text("So far you have contributed £0.00 to Overamped.")

                    VStack(alignment: .leading, spacing: 0) {
                        Toggle(
                            isOn: $showRecurringSubscriptions.animation(),
                            label: {
                                Text("Recurring Tip")
                            }
                        )
                        if showRecurringSubscriptions {
                            Text("Turn off to provide a one-off tip.")
                                .font(.caption)
                        } else {
                            Text("Turn on to provide a recurring monthly tip.")
                                .font(.caption)
                        }
                    }

                    HStack(spacing: 16) {
                        TipOptionView(
                            emoji: "☺️",
                            name: "Regular Tip",
                            price: "£0.99",
                            isRecurring: $showRecurringSubscriptions
                        )

                        TipOptionView(
                            emoji: "😃",
                            name: "Large Tip",
                            price: "£2.99",
                            isRecurring: $showRecurringSubscriptions
                        )

                        TipOptionView(
                            emoji: "🤩",
                            name: "Huge Tip",
                            price: "£4.99",
                            isRecurring: $showRecurringSubscriptions
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
        .navigationTitle("Support Overamped")
    }
}

struct TipOptionView: View {
    private let emoji: String
    private let name: String
    private let price: String
    @Binding private var isRecurring: Bool

    var body: some View {
        VStack {
            Text(emoji)
            Text(name)
            Spacer()
            if isRecurring {
                Text("\(price)\n/month")
            } else {
                Text(price)
            }
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding()
        .background(Color.accentColor.cornerRadius(16))
    }

    init(emoji: String, name: String, price: String, isRecurring: Binding<Bool>) {
        self.emoji = emoji
        self.name = name
        self.price = price
        _isRecurring = isRecurring
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
}
