import OverampedCore
import Persist
import XCTest

final class Overamped_Screenshots: XCTestCase {
    func testScreenshotApp() throws {
        // Go home to prevent "< Settings" in status bar
        XCUIDevice.shared.press(.home)
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

        var agreeGoogleCookiesText: String {
            if deviceLanguage == "ru-RU" {
                return "Принимаю"
            } else {
                return "I agree"
            }
        }

        let agreeToCookiesButton: XCUIElement = {
            if deviceLanguage == "ru-RU" {
                return safari.buttons["Принимаю"].firstMatch
            } else {
                return safari.buttons["I agree"].firstMatch
            }
        }()

        // Agree to Google's bullshit
        if !agreeToCookiesButton.waitForExistence(timeout: 5) {
            XCTFail("Couldn't find cookie agree button")
        }
        agreeToCookiesButton.tap()

        var enableDarkModeText: String {
            if deviceLanguage == "ru-RU" {
                return "Включить"
            } else {
                return "Turn on"
            }
        }

        if safari.buttons[enableDarkModeText].waitForExistence(timeout: 3) {
            safari.buttons[enableDarkModeText].tap()
        }

        snapshot("0 Google")

        /*
        // Disabled because Yandex keeps throwing up captchas and the "Access All" ("Принять") button isn't found
        if deviceLanguage == "ru-RU" {
            closeAllTabs(safari)
            typeInAddressField("https://yandex.ru/search/touch/?text=ios+15+web+extensions+appleinsider.ru", inSafari: safari)
            if safari.buttons["Принять"].waitForExistence(timeout: 1) {
                safari.buttons["Принять"].tap()
            }
            snapshot("1 Yandex")
        }
        */

        closeAllTabs(safari)
        typeInAddressField("https://twitter.com/Joe_Duffy/status/1435739074938146821", inSafari: safari)

        if safari.buttons["Not now"].waitForExistence(timeout: 3) {
            safari.buttons["Not now"].tap()
        }

        if safari.windows.firstMatch.horizontalSizeClass == .compact, safari.buttons["Close"].waitForExistence(timeout: 1) {
            // This is not working on iPads; it taps the link in the tweet
            safari.buttons["Close"].tap()
        }

        Thread.sleep(forTimeInterval: 1)

        safari.swipeDown()

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
        } else if settings.cells["Overamped"].exists {
            // Go back
            settings.buttons["Safari"].tap()
        }

        settings.cells["Clear History and Website Data"].tap()
        if settings.buttons["Clear History and Data"].exists {
            // Sheet on iPhone
            settings.buttons["Clear History and Data"].tap()
        } else if settings.buttons["Clear"].exists {
            // Alert on iPad
            settings.buttons["Clear"].tap()
        }
        settings.cells["Extensions"].tap()
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

        Thread.sleep(forTimeInterval: 1)
    }

    private func closeAllTabs(_ safari: XCUIApplication) {
        // Show tabs exposé
        safari.buttons["TabOverviewButton"].tap()

        let closeButtons = safari.buttons.matching(identifier: "Close")
        closeButtons.allElementsBoundByIndex.reversed().forEach { closeButton in
            closeButton.tap()
        }
    }

    private func typeInAddressField(_ text: String, inSafari safari: XCUIApplication) {
        let addressBarElement: XCUIElement

        switch safari.windows.firstMatch.horizontalSizeClass {
        case .compact, .unspecified:
            addressBarElement = safari.textFields.firstMatch
        case .regular:
            addressBarElement = safari.buttons.element(matching: NSPredicate(format: "identifier BEGINSWITH[c] %@", "UnifiedTabBarItemView"))
        @unknown default:
            addressBarElement = safari.textFields.firstMatch
        }

        guard addressBarElement.waitForExistence(timeout: 3) else {
            XCTFail("Couldn't find address bar element")
            return
        }

        addressBarElement.tap()

        if let url = URL(string: text) {
            UIPasteboard.general.url = url
        } else {
            UIPasteboard.general.string = text
        }
        safari.textFields.firstMatch.doubleTap()
        safari.menuItems.firstMatch.tap()
        safari.textFields.firstMatch.typeText("\n")
    }
}
