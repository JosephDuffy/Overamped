//
//  InstallationInstructionsView.swift
//  Overamped
//
//  Created by Joseph Duffy on 10/07/2021.
//

import SwiftUI

struct InstallationInstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Spacer()
                    Image("LargeIcon")
                    Spacer()
                }

                Text("""
                    The Overamped extension can be enabled from within Safari.

                    Start by opening Safari and opening a web page, such as a Google search. Tap the bar at the bottom, then tap the “More” button:
                    """)

                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.accentColor)
                    .font(.title2)

                Group {
                    Text("Then choose “Extensions”:")

                    HStack {
                        Text("Extensions")
                        Spacer()
                        Image(systemName: "puzzlepiece")
                    }
                    .padding()
                    .background(
                        Color(.secondarySystemBackground)
                            .cornerRadius(12)
                    )

                    Text("Turn “Overamped” on:")

                    HStack {
                        Image("LargeIcon")
                            .resizable()
                            .frame(width: 38, height: 38)
                        Text("Overamped")
                        Spacer()
                        Toggle(isOn: .constant(true), label: {})
                            .allowsHitTesting(false)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal)
                    .background(
                        Color(.secondarySystemBackground)
                            .cornerRadius(12)
                    )

                    Text("And tap “Done”:")

                    HStack {
                        Button("Done") {}
                        .opacity(0)
                        .allowsHitTesting(false)
                        Spacer()
                        Text("Extensions")
                        Spacer()
                        Button("Done") {}
                        .allowsHitTesting(false)
                    }
                    .font(.body.bold())
                    .padding()
                    .background(
                        Color(.secondarySystemBackground)
                    )
                    .clipShape(
                        RoundedCorner(
                            radius: 12,
                            corners: [.topLeft, .topRight]
                        )
                    )
                }

                Group {
                    Text("Select Overamped:")

                    HStack {
                        Text("Overamped")
                        Spacer()
                        Image("ToolbarIcon")
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(
                        Color(.secondarySystemBackground)
                            .cornerRadius(12)
                    )

                    Text("Choose “Always Allow...”:")

                    HStack {
                        Button("Always Allow...") {}
                        .frame(maxWidth: .infinity)
                        .allowsHitTesting(false)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)

                    Text("Providing access to all websites will ensure all AMP links are redirected, including links in Google search results, any website, and opened via apps.")

                    HStack {
                        Button("Always Allow on Every Website...") {}
                        .frame(maxWidth: .infinity)
                        .allowsHitTesting(false)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                }

                Text("From now on you should never see an AMP or Yandex Turbo page again!")
            }
            .padding()
        }
        .navigationTitle("Installation Instructions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InstallationInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstallationInstructionsView()
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension HorizontalAlignment {
    private enum HCenterAlignment: AlignmentID {
        static func defaultValue(in dimensions: ViewDimensions) -> CGFloat {
            return dimensions[HorizontalAlignment.center]
        }
    }
    static let hCenterred = HorizontalAlignment(HCenterAlignment.self)
}

