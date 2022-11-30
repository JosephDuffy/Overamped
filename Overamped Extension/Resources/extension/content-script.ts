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
import ExtensionApplicator from "./ExtensionApplicator"
import NativeAppCommunicator from "overamped-shared/NativeAppCommunicator"
import redirectToCanonicalVersion from "./generic-amp-content"
import overrideAMPArticles from "./google-news-article"
import redirectGoogleAMPContent from "./google-amp-content"
import replaceYahooJPAMPLinks from "./yahoo-jp-search-content"
import redirectYandexTurboCache from "./yandex-turbo-cache"
import redirectInstallChecker from "./install-checker"
;(async () => {
  const pageURL = new URL(location.toString())

  console.debug(`Webpage hostname: ${pageURL.hostname}`)

  const pageType = pageTypeForURL(pageURL)

  if (pageType == PageType.InstallChecker) {
    new ExtensionApplicator(document, redirectInstallChecker, false, [])
    return
  }

  const nativeAppCommunicator = new NativeAppCommunicator()
  const appSettings = await nativeAppCommunicator.appSettings()

  if (appSettings.redirectOnly) {
    console.debug("User has requested to only use generic AMP handler")
    new ExtensionApplicator(
      document,
      redirectToCanonicalVersion,
      false,
      appSettings.ignoredHostnames,
    )
    return
  }

  switch (pageType) {
    case PageType.GoogleNews:
      console.debug("Loading Google News Article handler")
      new ExtensionApplicator(
        document,
        overrideAMPArticles,
        true,
        appSettings.ignoredHostnames,
      )
      break
    case PageType.GoogleSearch:
      console.debug(
        "Not loading Google Search handler due to bug with handling Google Images; loading generic AMP hander",
      )
      // import("./google-search-content")
      new ExtensionApplicator(
        document,
        redirectToCanonicalVersion,
        false,
        appSettings.ignoredHostnames,
      )
      break
    case PageType.GoogleAMPCache:
      console.debug("Loading Google AMP Content handler")
      new ExtensionApplicator(
        document,
        redirectGoogleAMPContent,
        false,
        appSettings.ignoredHostnames,
      )
      break
    case PageType.YahooJAPANSearch:
      console.debug("Loading Yahoo JAPAN! Search handler")
      new ExtensionApplicator(
        document,
        replaceYahooJPAMPLinks,
        true,
        appSettings.ignoredHostnames,
      )
      break
    case PageType.YandexTurboCache:
      console.debug("Loading Yandex Turbo Cache handler")
      new ExtensionApplicator(
        document,
        redirectYandexTurboCache,
        false,
        appSettings.ignoredHostnames,
      )
      break
    case PageType.Unknown:
      // Fallback to try redirecting this page if it's an AMP page
      console.debug("Falling back to generic AMP handler")
      new ExtensionApplicator(
        document,
        redirectToCanonicalVersion,
        false,
        appSettings.ignoredHostnames,
      )
      break
  }
})()
