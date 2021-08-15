import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    private let activityItems: () -> [Any]
    private let applicationActivities: [UIActivity]?
    private let completion: UIActivityViewController.CompletionWithItemsHandler?

    @Binding var isPresented: Bool

    init(isPresented: Binding<Bool>, items: @escaping () -> [Any], activities: [UIActivity]? = nil, onComplete: UIActivityViewController.CompletionWithItemsHandler? = nil) {
        _isPresented = isPresented
        activityItems = items
        applicationActivities = activities
        completion = onComplete
    }

    func makeUIViewController(context: Context) -> ActivityViewControllerWrapper {
        ActivityViewControllerWrapper(isPresented: $isPresented, activityItems: activityItems(), applicationActivities: applicationActivities, onComplete: completion)
    }

    func updateUIViewController(_ uiViewController: ActivityViewControllerWrapper, context: Context) {
        uiViewController.activityItems = activityItems()
        uiViewController.completion = completion
        uiViewController.isPresented = $isPresented
        uiViewController.updateState()
    }
}

final class ActivityViewControllerWrapper: UIViewController {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]?
    var isPresented: Binding<Bool>
    var completion: UIActivityViewController.CompletionWithItemsHandler?

    init(isPresented: Binding<Bool>, activityItems: [Any], applicationActivities: [UIActivity]? = nil, onComplete: UIActivityViewController.CompletionWithItemsHandler? = nil) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
        self.isPresented = isPresented
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        updateState()
    }

    fileprivate func updateState() {
        let isActivityPresented = presentedViewController != nil

        guard isActivityPresented != isPresented.wrappedValue, !isActivityPresented else { return }

        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.popoverPresentationController?.sourceView = view
        controller.completionWithItemsHandler = { [weak self] (activityType, success, items, error) in
            self?.isPresented.wrappedValue = false
            self?.completion?(activityType, success, items, error)
        }
        present(controller, animated: true, completion: nil)
    }
}

public final class URLUIActivityItemSource: NSObject, UIActivityItemSource {
    public let url: URL

    public required init(url: URL) {
        self.url = url
    }

    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        url
    }

    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        switch activityType {
        case UIActivity.ActivityType.copyToPasteboard:
            // Returning the URL for Copy causes iOS to copy nothing
            return url.absoluteString
        default:
            return url
        }
    }
}
