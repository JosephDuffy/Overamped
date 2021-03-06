import XCTest

final class Overamped_Extension_UI_Tests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testEnablingRemovesAllAMPLogos() throws {
        // Main app must've been launched for share extension to be available
        let app = XCUIApplication()
        app.launch()

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.activate()

        func tapBottomBar() {
            safari.coordinate(withNormalizedOffset: CGVector(dx: UIScreen.main.bounds.width / 2, dy: UIScreen.main.bounds.width - 5)).tap()
        }

        // Used to be necessary in iOS 15 beta 2 but Safari now opens with the bottom bar expanded in beta 3
//        tapBottomBar()

        // Create a new tab
        safari.buttons["TabOverviewButton"].tap()
        safari.buttons["AddTabButton"].tap()

        safari.textFields.firstMatch.typeText("iOS 15 beta news\n")

        tapBottomBar()

        // Ensure extension is initially disabled
        safari.buttons["MoreOptionsButton"].tap()
        safari.collectionViews.buttons["Extensions"].tap()

        let overampedExtensionSwitch = safari.switches["Overamped"]

        if overampedExtensionSwitch.value as? String == "1" {
            overampedExtensionSwitch.tap()
        }

        safari.buttons["Done"].tap()
        safari.buttons["Reload"].tap()

        XCTAssertTrue(safari.links.element(matching: NSPredicate(format: "label == \"AMP logo\"")).waitForExistence(timeout: 5))

        // Enable extension
        tapBottomBar()
        safari.buttons["MoreOptionsButton"].tap()
        safari.collectionViews.buttons["Extensions"].tap()
        overampedExtensionSwitch.tap()
        // Close Extensions sheet
        safari.buttons["Done"].tap()
        // Close partial sheet
        safari.buttons["Close"].tap()

        XCTAssertTrue(safari.links.element(matching: NSPredicate(format: "label == \"Images\"")).waitForExistence(timeout: 5))
        XCTAssertFalse(safari.links.element(matching: NSPredicate(format: "label == \"AMP logo\"")).exists)
    }
}
