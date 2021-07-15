import deampURL from "./deampURL"

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

function testURLIsTransformed(input: string, expectedOutput: string) {
  const inputURL = new URL(input)
  const outputURL = deampURL(inputURL)
  expect(outputURL.toString()).toEqual(expectedOutput)
}
