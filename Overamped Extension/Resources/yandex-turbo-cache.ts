import ExtensionApplicator from "./ExtensionApplicator"
import NativeAppCommunicator from "./NativeAppCommunicator"

function redirectToCanonicalVersion(ignoredHostnames: string[]) {
  const canonicalElement: HTMLLinkElement | null = document.head.querySelector(
    "link[rel~='canonical'][href]",
  )

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

new ExtensionApplicator(document, redirectToCanonicalVersion, false)
