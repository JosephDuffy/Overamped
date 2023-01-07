import NativeAppCommunicator from "./NativeAppCommunicator"
import "./Array+compactMap"

function findAMPLogoRelativeToAnchor(
  anchor: HTMLAnchorElement,
): HTMLDivElement | null {
  const childLogo = anchor.querySelector("div.sw-Cite__icon--amp")

  if (childLogo) {
    return childLogo as HTMLDivElement
  }

  console.debug("Failed to find corresponding AMP logo <span> for", anchor)

  return null
}

// eslint-disable-next-line require-await
export default async function replaceYahooJPAMPLinks(
  ignoredHostnames: string[],
): Promise<void> {
  const ampAnchor = document.body.querySelectorAll("a[data-amp-cur]")
  console.debug(`Found ${ampAnchor.length} AMP links`)

  const modifiedURLs = Array.from(ampAnchor).map((element) => {
    const anchor = element as HTMLAnchorElement & {
      dataset: { ampCur: string }
    }
    try {
      return modifyAnchorIfRequired(anchor, ignoredHostnames)
    } catch (error) {
      // The URL of the anchor could be invalid. Rare but worth catching
      console.error("Failed to modify anchor", error)
      return undefined
    }
  })

  const newlyReplacedURLs = modifiedURLs.compactMap((element) => {
    return element
  })

  new NativeAppCommunicator().logReplacedLinks(newlyReplacedURLs)
}

function modifyAnchorIfRequired(
  anchor: HTMLAnchorElement & { dataset: { ampCur: string } },
  ignoredHostnames: string[],
): URL | undefined {
  console.debug("Checking anchor", anchor)

  const canonicalWebsiteAnchors =
    anchor.nextElementSibling?.getElementsByTagName("a")

  if (
    canonicalWebsiteAnchors === undefined ||
    canonicalWebsiteAnchors.length !== 1
  ) {
    console.debug("Couldn't find anchor containing canonical link")
    return
  }

  const canonicalWebsiteAnchor = canonicalWebsiteAnchors[0]
  const canonicalWebsite = new URL(canonicalWebsiteAnchor.href)

  if (ignoredHostnames.includes(canonicalWebsite.hostname)) {
    console.debug(
      `Not modifying anchor; ${canonicalWebsite.hostname} is in ignore list`,
    )

    return
  }

  anchor.href = canonicalWebsite.toString()

  const ampIcon = findAMPLogoRelativeToAnchor(anchor)

  if (ampIcon) {
    ampIcon.style.display = "none"
  }

  return canonicalWebsite
}
