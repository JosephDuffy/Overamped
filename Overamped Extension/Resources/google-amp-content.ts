import deAMPURL from "./deAMPURL"
import ExtensionApplicator from "./ExtensionApplicator"
import openURL from "./openURL"

async function redirectToCanonicalVersion(
  ignoredHostnames: string[],
): Promise<void> {
  const canonicalAnchor: HTMLAnchorElement | null =
    document.querySelector("a.amp-canurl")

  if (canonicalAnchor) {
    // This is the actual URL of the non-AMP page
    const canonicalURL = new URL(canonicalAnchor.href)

    openURL(canonicalURL, ignoredHostnames, true, "replace")
  } else if (document.readyState === "complete") {
    // Google may have changed something so the canonical link is used as a fallback.
    // This isn't ideal because the canonical link is the AMP version of the website
    // hosted by the website, not the actual canonical non-AMP version.
    const canonicalElement: HTMLLinkElement | null =
      document.head.querySelector("link[rel~='canonical'][href]")

    if (!canonicalElement) {
      console.debug("Couldn't find canonical URL to redirect to")
      return Promise.resolve()
    }

    const canonicalURL = new URL(canonicalElement.href)

    const { canAccess: canAccessURL } = await browser.runtime.sendMessage({
      request: "canAccessURL",
      payload: {
        url: canonicalURL.toString(),
      },
    })

    if (canAccessURL) {
      // The canonical AMP page can be redirected
      openURL(canonicalURL, ignoredHostnames, false, "replace")
    } else {
      // Only de-AMP the URL if redirecting to the AMP URL
      // wouldn't be redirected.
      const deAMPedURL = deAMPURL(canonicalURL)
      console.debug(`De-AMPed URL: ${deAMPedURL}`)
      openURL(canonicalURL, ignoredHostnames, true, "replace")
    }
  }
  return Promise.resolve()
}

new ExtensionApplicator(document, redirectToCanonicalVersion, false)
