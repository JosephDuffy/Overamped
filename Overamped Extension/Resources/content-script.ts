/**
 * Prior to version 1.1.0 each domain's script was injected only on that domain. However this causes
 * a very long list of domains to be displayed in the iOS Settings app when setting up permissions.
 *
 * This could be quite confusing for users, especially since the "Other Websites" option is at the bottom.
 *
 * This approach has some small downsides: the content script will be much larger and the loading of the script
 * will be a little slower.
 */

import pageTypeForURL, { PageType } from "./pageTypeForURL"

const pageURL = new URL(location.toString())

console.debug(`Webpage hostname: ${pageURL.hostname}`)

const pageType = pageTypeForURL(pageURL)

switch (pageType) {
  case PageType.GoogleNews:
    console.debug("Loading Google News Article handler")
    import("./google-news-article")
    break
  case PageType.GoogleSearch:
    console.debug("Loading Google Search handler")
    import("./google-search-content")
    break
  case PageType.GoogleAMPCache:
    console.debug("Loading Google AMP Content handler")
    import("./google-amp-content")
    break
  case PageType.YahooJAPANSearch:
    console.debug("Loading Yahoo JAPAN! Search handler")
    import("./yahoo-jp-search-content")
    break
  case PageType.YandexTurboCache:
    console.debug("Loading Yandex Turbo Cache handler")
    import("./yandex-turbo-cache")
    break
  case PageType.Unknown:
    // Fallback to try redirecting this page is it's an AMP page
    console.debug("Loading Generic AMP handler")
    import("./generic-amp-content")
    break
}
