import deampURL from "./deampURL"
import ExtensionApplier from "./ExtensionApplier"

function redirectToCanonicalVersion(ignoredHostnames: string[]) {
  const canonicalElement: HTMLLinkElement | null = document.head.querySelector(
    "link[rel~='canonical'][href]",
  )

  if (!canonicalElement) {
    console.debug("Couldn't find canonical URL to redirect to")
    return
  }

  const canonicalURL = new URL(canonicalElement.href)
  const finalURL = deampURL(canonicalURL)

  if (ignoredHostnames.includes(finalURL.hostname)) {
    console.info(
      `Not redirecting because ${finalURL.hostname} is in the ignored hostnames`,
    )
  } else {
    console.log(`Redirecting AMP page to ${finalURL.toString()}`)

    window.location.replace(finalURL.toString())
  }
}

new ExtensionApplier(document, redirectToCanonicalVersion)
