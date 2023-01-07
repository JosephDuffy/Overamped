import openURL from "./openURL"

/**
 * Redirect from Yahoo!JAPAN's AMP viewer to the canonical page.
 *
 * @param ignoredHostnames An array of hostnames to not redirect to.
 * @returns A promise that fulfils when the redirection is complete.
 */
export default function redirectYahooJAPANAMPContent(
  ignoredHostnames: string[],
): Promise<void> {
  /** A top-level container, displaying the AMP header and the AMP page */
  const overallPageContainer = document.getElementsByClassName("AmpViewer")

  if (overallPageContainer.length === 0) {
    return Promise.resolve()
  }

  const canonicalLink = document.querySelector(
    "link[rel='canonical'][href]",
  ) as HTMLLinkElement | null

  if (canonicalLink !== null) {
    /** The canonical non-AMP URL of AMP page being displayed */
    const canonicalURL = new URL(canonicalLink.href)

    openURL(canonicalURL, ignoredHostnames, true, "AMP", "replace")
  }

  return Promise.resolve()
}
