import ExtensionApplicator from "./ExtensionApplicator"
import openURL from "./openURL"

function redirectToCanonicalVersion(ignoredHostnames: string[]): Promise<void> {
  const documentAttributes = document.documentElement.attributes

  if (
    !Object.prototype.hasOwnProperty.call(documentAttributes, "amp") &&
    !Object.prototype.hasOwnProperty.call(documentAttributes, "⚡")
  ) {
    return Promise.resolve()
  }

  const canonicalElement: HTMLLinkElement | null = document.head.querySelector(
    "link[rel~='canonical'][href]",
  )

  if (!canonicalElement) {
    console.debug("Couldn't find canonical URL to redirect to")
    return Promise.resolve()
  }

  const canonicalURL = new URL(canonicalElement.href)

  openURL(canonicalURL, ignoredHostnames, true, "replace")

  return Promise.resolve()
}

new ExtensionApplicator(document, redirectToCanonicalVersion, false)
