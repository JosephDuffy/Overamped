import openURL from "./openURL"

export default function redirectToCanonicalVersion(
  ignoredHostnames: string[],
): Promise<void> {
  const documentAttributes = document.documentElement.attributes

  if (
    !Object.prototype.hasOwnProperty.call(documentAttributes, "amp") &&
    !Object.prototype.hasOwnProperty.call(documentAttributes, "⚡")
  ) {
    return Promise.resolve()
  }

  const canonicalElement = document.head.querySelector(
    "link[rel~='canonical'][href]",
  ) as HTMLLinkElement | null

  if (!canonicalElement) {
    console.debug("Couldn't find canonical URL to redirect to")
    return Promise.resolve()
  }

  const canonicalURL = new URL(canonicalElement.href)

  if (
    canonicalURL.toString() === document.referrer ||
    document.referrer === document.location.toString()
  ) {
    console.info(
      "Not redirecting to AMP page due to recursive redirect; redirecting this page would redirect back to this AMP page",
    )
    return Promise.resolve()
  }

  openURL(canonicalURL, ignoredHostnames, true, "AMP", "replace")

  return Promise.resolve()
}
