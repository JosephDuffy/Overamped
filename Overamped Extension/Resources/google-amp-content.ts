import ExtensionApplicator from "./ExtensionApplicator"
import NativeAppCommunicator from "./NativeAppCommunicator"

function redirectToCanonicalVersion(ignoredHostnames: string[]) {
  const canonicalAnchor: HTMLAnchorElement | null =
    document.querySelector("a.amp-canurl")

  if (canonicalAnchor) {
    // This is the actual URL of the non-AMP page
    const canonicalURL = new URL(canonicalAnchor.href)

    if (ignoredHostnames.includes(canonicalURL.hostname)) {
      console.info(
        `Not redirecting because ${canonicalURL.hostname} is in the ignored hostnames`,
      )
    } else {
      console.log(`Redirecting AMP page to ${canonicalURL.toString()}`)

      new NativeAppCommunicator().logRedirectedLink(canonicalURL)

      window.location.replace(canonicalURL.toString())
    }
  } else if (document.readyState === "complete") {
    // Google may have changed something so the canonical link is used as a fallback.
    // This isn't ideal because the canonical link is the AMP version of the website
    // hosted by the website, not the actual canonical non-AMP version.
    const canonicalElement: HTMLLinkElement | null =
      document.head.querySelector("link[rel~='canonical'][href]")

    if (!canonicalElement) {
      console.debug("Couldn't find canonical URL to redirect to")
      return
    }

    const canonicalURL = new URL(canonicalElement.href)

    if (ignoredHostnames.includes(canonicalURL.hostname)) {
      console.info(
        `Not redirecting because ${canonicalURL.hostname} is in the ignored hostnames`,
      )
    } else {
      console.log(`Redirecting AMP page to ${canonicalURL.toString()}`)

      new NativeAppCommunicator().logRedirectedLink(canonicalURL)

      window.location.replace(canonicalURL.toString())
    }
  }
}

new ExtensionApplicator(document, redirectToCanonicalVersion, false)
