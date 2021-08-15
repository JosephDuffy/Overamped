import SwiftUI

struct Acknowledgements: View {
    private var acknowledgements: [Acknowledgement] = []
    @SceneStorage("Acknowledgements.displayedAcknowledgement") private var displayedAcknowledgement: URL?

    var body: some View {
        List {
            Section() {
                ForEach(acknowledgements, id: \.url) { acknowledgement in
                    NavigationLink(acknowledgement.name, tag: acknowledgement.url, selection: $displayedAcknowledgement) {
                        AcknowledgementView(acknowledgement: acknowledgement)
                    }
                }
            }
        }
        .navigationTitle("Acknowledgements")
    }

    init() {
        acknowledgements = [
            Acknowledgement(
                name: "Persist",
                url: URL(string: "https://github.com/JosephDuffy/Persist")!,
                licenseText: """
MIT License

Copyright (c) 2020 Joseph Duffy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""
            )
        ]
    }
}

struct AcknowledgementView: View {
    private let acknowledgement: Acknowledgement

    var body: some View {
        List {
            Section("Source") {
                Link(acknowledgement.url.absoluteString, destination: acknowledgement.url)
            }

            Section("License") {
                Text(acknowledgement.licenseText)
            }
        }
        .navigationTitle(acknowledgement.name)
    }

    init(acknowledgement: Acknowledgement){
        self.acknowledgement = acknowledgement
    }
}

struct Acknowledgement: Hashable {
    let name: String
    let url: URL
    let licenseText: String
}
