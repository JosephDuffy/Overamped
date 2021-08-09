import deAMPURL from "./deAMPURL"

test("/amp/ prefix is removed", () => {
  testURLIsTransformed(
    "https://example.com/amp/news/ios15-beta-news/",
    "https://example.com/news/ios15-beta-news/",
  )
})

test("/amp/ suffix is removed", () => {
  testURLIsTransformed(
    "https://example.com/news/ios15-beta-news/amp/",
    "https://example.com/news/ios15-beta-news/",
  )
})

test(".amp suffix is removed", () => {
  testURLIsTransformed(
    "https://example.com/news/ios15-beta-news.amp",
    "https://example.com/news/ios15-beta-news",
  )
})

test("amp subdomain is removed", () => {
  testURLIsTransformed(
    "https://amp.example.com/news/ios15-beta-news",
    "https://example.com/news/ios15-beta-news",
  )
})

test("amp query item is removed", () => {
  testURLIsTransformed(
    "https://example.com/news/ios15-beta-news?amp=1&other=value",
    "https://example.com/news/ios15-beta-news?other=value",
  )
})

test("amp is not removed from domain", () => {
  testURLIsTransformed(
    "https://amp.com/news/ios15-beta-news?amp=1&other=value",
    "https://amp.com/news/ios15-beta-news?other=value",
  )
})

test("abc.net.au is transformed correctly", () => {
  testURLIsTransformed(
    "https://amp.abc.net.au/article/100361158",
    "https://www.abc.net.au/news/100361158",
  )
})

function testURLIsTransformed(input: string, expectedOutput: string) {
  const inputURL = new URL(input)
  const outputURL = deAMPURL(inputURL)
  expect(outputURL.toString()).toEqual(expectedOutput)
}
