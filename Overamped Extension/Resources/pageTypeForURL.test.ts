import pageTypeForURL, { PageType, googleDomains } from "./pageTypeForURL"

test("Google News URLs", () => {
  const googleNewsURLs = googleDomains.map((googleDomain) => {
    // console.log("googleDomain", `https://news.${googleDomain}`)
    return new URL("/", `https://news.${googleDomain}`)
  })
  // console.log("googleNewsURLs", googleNewsURLs)
  googleNewsURLs.forEach((ampURL) => {
    const pageType = pageTypeForURL(ampURL)
    expect(pageType).toEqual(PageType.GoogleNews)
  })
})

test("Google News forYou URLs", () => {
  const googleNewsURLs = googleDomains.map((googleDomain) => {
    return new URL(`https://news.${googleDomain}/foryou`)
  })
  googleNewsURLs.forEach((ampURL) => {
    const pageType = pageTypeForURL(ampURL)
    expect(pageType).toEqual(PageType.GoogleNews)
  })
})

test("Google AMP URLs", () => {
  const googleAMPURLs = googleDomains.map((googleDomain) => {
    return new URL(`https://${googleDomain}/amp/s/example.com`)
  })
  googleAMPURLs.forEach((ampURL) => {
    const pageType = pageTypeForURL(ampURL)
    expect(pageType).toEqual(PageType.GoogleAMPCache)
  })
})

test("Google search URLs", () => {
  const googleSearch = googleDomains.map((googleDomain) => {
    return new URL(`https://${googleDomain}/search?q=Overamped`)
  })
  googleSearch.forEach((ampURL) => {
    const pageType = pageTypeForURL(ampURL)
    expect(pageType).toEqual(PageType.GoogleSearch)
  })
})

test("Yahoo JAPAN! Search URL", () => {
  const url = new URL("https://search.yahoo.co.jp/search?=Overamped")
  const pageType = pageTypeForURL(url)
  expect(pageType).toEqual(PageType.YahooJAPANSearch)
})

test("Yandex Turbo URL without subdomain", () => {
  const url = new URL("https://turbopages.org")
  const pageType = pageTypeForURL(url)
  expect(pageType).toEqual(PageType.Unknown)
})

test("Yandex Turbo URL with subdomain", () => {
  const url = new URL("https://example.com.turbopages.org")
  const pageType = pageTypeForURL(url)
  expect(pageType).toEqual(PageType.YandexTurboCache)
})
