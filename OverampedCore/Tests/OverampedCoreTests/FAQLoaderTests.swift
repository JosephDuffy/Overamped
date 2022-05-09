import XCTest
@testable import OverampedCore

final class FAQLoaderTests: XCTestCase {
    override class func tearDown() {
        OverampedURLProtocol.responseProviders = [:]
    }

    @MainActor
    func testLoadingFromAPI() async throws {
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [OverampedURLProtocol.self]
        let session = URLSession(configuration: urlSessionConfig)

        var expectCachingHeaders = false

        let apiURL = URL(string: "https://overamped.app/api/faq")!
        OverampedURLProtocol.responseProviders[apiURL] = { request in
            if request.value(forHTTPHeaderField: "If-Modified-Since") != nil {
                return (HTTPURLResponse(url: apiURL, statusCode: 304, httpVersion: "HTTP/1.1", headerFields: nil), nil)
            } else {
                if expectCachingHeaders {
                    XCTFail("Should send caching header")
                }

                let body = #"[{"title":"Test Question","answer":["Test Answer"],"platforms":["app","website"]}]"#
                let response = HTTPURLResponse(
                    url: apiURL,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: [
                        "Content-Length": "\(Data(body.utf8).count)",
                        "Content-Type": "application/json; charset=utf-8",
                        "Etag": "\"c28-mWQ8vwpdj+VRIlkDMUff5ZNR6Y4\"",
                        "Cache-Control": "public, must-revalidate",

                    ]
                )
                return (response, Data(body.utf8))
            }
        }

        let loader = FAQLoader()
        await loader.loadLatestQuestions(session: session)

        XCTAssertEqual(loader.questions.count, 1)

        expectCachingHeaders = true

        await loader.loadLatestQuestions(session: session)
        XCTAssertEqual(loader.questions.count, 1)
    }
}

public final class OverampedURLProtocol: URLProtocol {
    public typealias ResponseProvider = (_ request: URLRequest) throws -> (URLResponse?, Data?)

    public static var responseProviders: [URL: ResponseProvider] = [:]

    override public class func canInit(with task: URLSessionTask) -> Bool {
        guard let url = task.originalRequest?.url else { return false }
        return responseProviders.keys.contains(url)
    }

    public override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        return responseProviders.keys.contains(url)
    }

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override public func startLoading() {
        guard let client = client else { return }

        defer {
            client.urlProtocolDidFinishLoading(self)
        }

        let requestURL = request.url!
        let responseProvider = Self.responseProviders[requestURL]!

        do {
            let (urlResponse, data) = try responseProvider(request)

            if
                let urlResponse = urlResponse,
                let httpResponse = urlResponse as? HTTPURLResponse,
                let responseETag = httpResponse.value(forHTTPHeaderField: "Etag"),
                let requestETag = request.value(forHTTPHeaderField: "If-None-Match"),
                requestETag == responseETag
            {
                let cachedResponse = CachedURLResponse(response: urlResponse, data: data ?? Data())
                client.urlProtocol(self, cachedResponseIsValid: cachedResponse)
                return
            }

            if let cachedResponse = cachedResponse {
                client.urlProtocol(self, cachedResponseIsValid: cachedResponse)
                return
            }

            urlResponse.map { client.urlProtocol(self, didReceive: $0, cacheStoragePolicy: .allowed) }
            data.map { client.urlProtocol(self, didLoad: $0) }
        } catch {
            client.urlProtocol(self, didFailWithError: error)
        }
    }

    override public func stopLoading() {}
}
