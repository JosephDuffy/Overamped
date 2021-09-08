import OverampedCore
import Persist
import XCTest

final class Overamped_Screenshots: XCTestCase {
    func testScreenshotApp() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uiTests")
        setupSnapshot(app)
        app.launch()
        switch app.windows.firstMatch.horizontalSizeClass {
        case .compact, .unspecified:
            XCUIDevice.shared.orientation = .portrait
        case .regular:
            XCUIDevice.shared.orientation = .landscapeLeft
        @unknown default:
            XCUIDevice.shared.orientation = .portrait
        }

        app.buttons["Statistics"].tap()

        snapshot("3 Statistics")

        app.buttons["Settings"].tap()

        if !app.staticTexts["9to5mac.com"].exists {
            app.cells.element(matching: NSPredicate(format: "label BEGINSWITH[c] %@", "Disabled Websites")).tap()
        }

        snapshot("4 Disabled Websites")
    }

    func testSafariScreenshots() throws {
        enableExtension()

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        setupSnapshot(safari)
        // When `-ui_testing` is passed Safari won't launch
        safari.launchArguments.removeAll(where: { $0 == "-ui_testing" })
        safari.launch()

        switch safari.windows.firstMatch.horizontalSizeClass {
        case .compact, .unspecified:
            XCUIDevice.shared.orientation = .portrait
        case .regular:
            XCUIDevice.shared.orientation = .landscapeLeft
        @unknown default:
            XCUIDevice.shared.orientation = .portrait
        }

        closeAllTabs(safari)
        typeInAddressField("iOS 15 web extensions news", inSafari: safari)

        // Agree to Google's bullshit
        if safari.buttons["I agree"].waitForExistence(timeout: 1) {
            // Wait for bottom bar to disappear
//            Thread.sleep(forTimeInterval: 3)
            safari.buttons["I agree"].tap()
        }

        snapshot("0 Google")

        if Locale.current.regionCode == "RU" {
            closeAllTabs(safari)
            typeInAddressField("https://yandex.ru/search/touch/?text=ios+15+web+extensions+appleinsider.ru", inSafari: safari)
            snapshot("1 Yandex")
        }

        closeAllTabs(safari)
        typeInAddressField("https://www.reddit.com/r/XboxSeriesX/comments/pa6hlj/", inSafari: safari)

        if safari.buttons["Continue"].waitForExistence(timeout: 1) {
            // Wait for bottom bar to disappear
//            Thread.sleep(forTimeInterval: 3)
            safari.buttons["Continue"].tap()
        }

        if safari.staticTexts["This page looks better in the app"].waitForExistence(timeout: 1), safari.buttons.firstMatch.label.isEmpty {
            // Should be the "X" in the "This page looks better in the app" banner
            safari.buttons.firstMatch.tap()
        }

        snapshot("2 Other Websites")
    }

    private func enableExtension() {
        // Main app must've been launched for share extension to be available
        let app = XCUIApplication()
        app.launch()

        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settings.launch()

        if settings.cells["Safari"].exists {
            settings.cells["Safari"].tap()
        }
        if settings.cells["Extensions"].exists {
            settings.cells["Extensions"].tap()
        }
        settings.cells["Overamped"].tap()

        let enableSwitch = settings.switches["Overamped"]

        if !(enableSwitch.value as? String == "1") {
            enableSwitch.tap()
        }

        let otherWebsites = settings.cells["Other Websites"]
        if !(otherWebsites.value as? String == "Allow") {
            otherWebsites.tap()
            settings.cells["Allow"].tap()
            settings.navigationBars.buttons["Overamped"].tap()
        }

        // Go home to prevent "< Settings" in status bar
        XCUIDevice.shared.press(.home)

        Thread.sleep(forTimeInterval: 0.5)
    }

    private func closeAllTabs(_ safari: XCUIApplication) {
        if safari.otherElements["CapsuleNavigationBar?isSelected=true"].exists {
            safari.otherElements["CapsuleNavigationBar?isSelected=true"].tap()
        }

        if safari.buttons["TabOverviewButton"].exists {
            safari.buttons["TabOverviewButton"].tap()
        }

        let closeButtons = safari.buttons.matching(identifier: "Close")
        closeButtons.allElementsBoundByIndex.reversed().forEach { closeButton in
            closeButton.tap()
        }
    }

    private func typeInAddressField(_ text: String, inSafari safari: XCUIApplication) {
        if safari.buttons["Address"].exists {
            safari.buttons["Address"].tap()
            XCTAssertTrue(safari.textFields["Address"].waitForExistence(timeout: 1))
        } else if safari.textFields.firstMatch.waitForExistence(timeout: 1) {
            safari.textFields.firstMatch.tap()
        } else {
            print("No address button or text field")
        }

        safari.textFields.firstMatch.typeText(text + "\n")
    }
}
