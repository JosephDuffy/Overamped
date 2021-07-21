import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("""
                    Overamped is developed by Joseph Duffy, an indie developer.
                    """)

                Text("© Yetii Ltd. 2021. Overamped \(Bundle.main.appVersion) (\(Bundle.main.appBuild))")
            }
            .padding()
        }
        .navigationTitle("About Overamped")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
