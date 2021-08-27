import SwiftUI

public struct ReadableWidthView<Content: View>: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIViewController

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    init(content: Content) {
        self.content = content
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let view = viewController.view!
        view.backgroundColor = .clear

        let hostingController = UIHostingController(rootView: content)
        viewController.addChild(hostingController)

        hostingController.view.backgroundColor = .clear
        view.addSubview(hostingController.view)
        hostingController.view?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.readableContentGuide.bottomAnchor),
        ])
        hostingController.didMove(toParent: viewController)
        return viewController
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

extension View {
    func constrainedToReadableWidth() -> some View {
        self
    }
}
