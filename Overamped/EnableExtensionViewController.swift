import UIKit

final class EnableExtensionViewController: UIViewController {
    @IBOutlet private var extensionsRow: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        extensionsRow.layer.cornerRadius = 16
    }
}
