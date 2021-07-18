import XCTest
@testable import OverampedCore

final class DeepLinkTests: XCTestCase {
    func testAppSchemeWithSlashesFeedbackWithoutURL() throws {
        let url = URL(string: "overamped://feedback")!
        let deepLink = try XCTUnwrap(DeepLink(url: url))
        XCTAssertEqual(deepLink, .feedback(searchURL: nil, websiteURL: nil))
    }

    func testAppSchemeWithoutSlashesFeedbackWithoutURL() throws {
        let url = URL(string: "overamped:feedback")!
        let deepLink = try XCTUnwrap(DeepLink(url: url))
        XCTAssertEqual(deepLink, .feedback(searchURL: nil, websiteURL: nil))
    }

    func testWebURLFeedbackWithoutURL() throws {
        let url = URL(string: "https://overamped.app/feedback")!
        let deepLink = try XCTUnwrap(DeepLink(url: url))
        XCTAssertEqual(deepLink, .feedback(searchURL: nil, websiteURL: nil))
    }

    func testWebURLFeedbackWithURL() throws {
        let url = URL(string: "https://overamped.app/feedback?url=https://example.com")!
        let deepLink = try XCTUnwrap(DeepLink(url: url))
        XCTAssertEqual(deepLink, .feedback(searchURL: nil, websiteURL: "https://example.com"))
    }
}
