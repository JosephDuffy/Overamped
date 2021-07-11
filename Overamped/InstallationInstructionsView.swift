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

                Text("The Overamped extension can be enabled from within Safari.")

                Text("Start by opening Safari and performing a Google search. Tap the bar at the bottom, then tap the \"More\" button:")

                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.accentColor)

                Text("Then choose \"Extensions\":")

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

                Text("""
    Turn "Overamped" on and tap "Done".

    Tap "Overamed" to provide access to Google.

    Any AMP links on the current page or any other Google searches will be updated to the non-AMP version.
    """)
            }
            .padding()
        }
        .tabItem {
            VStack {
                Image(systemName: "puzzlepiece")
                Text("Install")
            }
        }
    }
}

struct InstallationInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstallationInstructionsView()
    }
}
