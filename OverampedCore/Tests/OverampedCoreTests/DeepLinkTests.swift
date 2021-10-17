import XCTest
@testable import OverampedCore

final class DeepLinkTests: XCTestCase {
    func testAppSchemeWithSlashesFeedbackWithoutURL() throws {
        let url = URL(string: "overamped://feedback")!
        let deepLink = try XCTUnwrap(DeepLink(url: url))
        XCTAssertEqual(deepLink, .websiteFeedback(websiteURL: nil, permittedOrigins: nil))
    }

    func testAppSchemeWithoutSlashesFeedbackWithoutURL() throws {
        let url = URL(string: "overamped:feedback")!
        let deepLink = try XCTUnwrap(DeepLink(url: url))
        XCTAssertEqual(deepLink, .websiteFeedback(websiteURL: nil, permittedOrigins: nil))
    }

    func testAppSchemeUnlock() throws {
        let url = URL(string: "overamped://unlock")!
        let deepLink = try XCTUnwrap(DeepLink(url: url))
        XCTAssertEqual(deepLink, .unlock)
    }

    func testWebURLFeedbackWithoutURL() throws {
        let url = URL(string: "https://overamped.app/feedback")!
        let deepLink = try XCTUnwrap(DeepLink(url: url))
        XCTAssertEqual(deepLink, .websiteFeedback(websiteURL: nil, permittedOrigins: nil))
    }

    func testWebURLFeedbackWithURL() throws {
        let url = URL(string: "https://overamped.app/feedback?url=https://example.com")!
        let deepLink = try XCTUnwrap(DeepLink(url: url))
        XCTAssertEqual(
            deepLink,
                .websiteFeedback(
                    websiteURL: URL(string: "https://example.com")!,
                    permittedOrigins: nil
                )
        )
    }

    func testWebURLFeedbackWithEmptyPermittedOrigins() throws {
        let url = URL(string: "https://overamped.app/feedback?url=https://example.com&permittedOrigins=")!
        let deepLink = try XCTUnwrap(DeepLink(url: url))
        XCTAssertEqual(
            deepLink,
                .websiteFeedback(
                    websiteURL: URL(string: "https://example.com")!,
                    permittedOrigins: []
                )
        )
    }

    func testWebURLFeedbackWithSinglePermittedOrigin() throws {
        let url = URL(string: "https://overamped.app/feedback?url=https://example.com&permittedOrigins=google.com")!
        let deepLink = try XCTUnwrap(DeepLink(url: url))
        XCTAssertEqual(
            deepLink,
            .websiteFeedback(
                websiteURL: URL(string: "https://example.com")!,
                permittedOrigins: ["google.com"]
            )
        )
    }

    func testWebURLFeedbackWithMultiplePermittedOrigins() throws {
        let url = URL(string: "https://overamped.app/feedback?url=https://example.com&permittedOrigins=google.com,google.co.uk")!
        let deepLink = try XCTUnwrap(DeepLink(url: url))
        XCTAssertEqual(
            deepLink,
            .websiteFeedback(
                websiteURL: URL(string: "https://example.com")!,
                permittedOrigins: ["google.com", "google.co.uk"]
            )
        )
    }
}
