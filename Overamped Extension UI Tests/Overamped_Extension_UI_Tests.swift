import XCTest

@MainActor
final class Overamped_Extension_UI_Tests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testEnablingRemovesAllAMPLogos() throws {
        // Main app must've been launched for web extension to be available.
        let app = XCUIApplication()
        app.launch()

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.activate()

        // Create a new tab.
        let tabOverviewButton = safari.buttons["TabOverviewButton"]
        let newTabButton = safari.toolbars.buttons["NewTabButton"]

        if !newTabButton.exists, tabOverviewButton.exists {
            tabOverviewButton.tap()
        }

        newTabButton.tap()

        // Navigate to install checker.
        let addressTextField = safari.textFields["Address"]
        addressTextField.tap()
        addressTextField.typeText("https://overamped.app/install-checker\n")

        // Enable extension.
        safari.buttons["PageFormatMenuButton"].tap()
        safari.cells["ManageExtensions"].tap()

        let overampedExtensionSwitch = safari.switches["Overamped"]

        if overampedExtensionSwitch.value as? String == "0" {
            overampedExtensionSwitch.tap()
        }

        safari.buttons["Done"].tap()
        safari.cells["Overamped"].tap()

        if safari.alerts.count > 0 {
            // Permission alert it showing.
            safari.alerts.buttons["Always Allow…"].tap()
            safari.alerts.buttons["Always Allow on Every Website"].tap()
        }

        if !safari.buttons["Done"].exists {
            safari.cells["Overamped"].tap()
        }
        safari.buttons["Done"].tap()

        // Check that install checker detected the extension.
        let extensionDetectedText = safari.staticTexts["✅ Overamped Safari Extension Detected"]

        XCTAssertTrue(extensionDetectedText.waitForExistence(timeout: 5))
    }
}
