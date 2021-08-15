import SafariServices
import SwiftUI

struct SafariView: UIViewControllerRepresentable {
    typealias DidFinishHandler = () -> Void

    let url: URL

    private let delegate: SafariViewDelegate?

    public init(url: URL, didFinishHandler: DidFinishHandler?) {
        self.url = url
        delegate = didFinishHandler.map(SafariViewDelegate.init(didFinishHandler:))
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = delegate
        return safariViewController
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {}
}

private final class SafariViewDelegate: NSObject, SFSafariViewControllerDelegate {
    typealias DidFinishHandler = () -> Void

    private let didFinishHandler: DidFinishHandler

    init(didFinishHandler: @escaping DidFinishHandler) {
        self.didFinishHandler = didFinishHandler

        super.init()
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        didFinishHandler()
    }
}
