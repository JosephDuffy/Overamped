import ExtensionApplicator from "./ExtensionApplicator"
import openURL from "./openURL"

function redirectToCanonicalVersion(ignoredHostnames: string[]): Promise<void> {
  const checkTokenElement = document.head.querySelector(
    "meta[name='overamped-check-token'][content]",
  ) as HTMLMetaElement | null

  const checkToken = checkTokenElement?.content

  if (!checkToken) {
    console.debug("Couldn't find overamped-check-token data attribute")
    return Promise.resolve()
  }

  const redirectURL = new URL(window.location.toString())
  redirectURL.searchParams.append("checkToken", checkToken)

  openURL(redirectURL, ignoredHostnames, true, "Install Checker", "replace")

  return Promise.resolve()
}

new ExtensionApplicator(document, redirectToCanonicalVersion, false)
