import XCTest
@testable import OverampedCore

final class URLTests: XCTestCase {
    func testHostnameWithSubdomain() throws {
        let url = URL(string: "https://subdomain.example.com/path")!
        XCTAssertEqual(url.hostname, "subdomain.example.com")
    }

    func testHostnameWithPort() throws {
        let url = URL(string: "https://subdomain.example.com:8080/path")!
        XCTAssertEqual(url.hostname, "subdomain.example.com")
    }

    func testHostnameWithoutHost() throws {
        let url = URL(string: "/path")!
        XCTAssertNil(url.hostname)
    }
}
