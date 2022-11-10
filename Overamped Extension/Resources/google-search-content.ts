import deAMPURL from "./deAMPURL"
import ExtensionApplicator from "./ExtensionApplicator"
import NativeAppCommunicator from "./NativeAppCommunicator"
import openURL from "./openURL"
import "./Array+compactMap"

new ExtensionApplicator(document, replaceAMPLinks, true)

interface OverriddenAnchor {
  listener: (event: MouseEvent) => boolean
  originalHREF: string
  ampIconDisplay?: string
}
const anchorOnclickListeners: {
  [ved: string]: OverriddenAnchor
} = {}

function findAMPLogoRelativeToAnchor(
  anchor: HTMLAnchorElement,
): HTMLSpanElement | null {
  const childLogo = anchor.querySelector("span[aria-label='AMP logo']")

  if (childLogo) {
    return childLogo as HTMLSpanElement
  }

  if (anchor.dataset.ampHlt) {
    console.debug(
      `Anchor is from a "Featured Snippet"; searching parent for container`,
    )
    // The "Featured Snippet" puts the logo outside of the anchor
    let parent = anchor.parentElement

    while (parent && !parent.classList.contains("card-section")) {
      parent = parent.parentElement
    }

    if (parent) {
      console.debug("Found card section parent", parent)
      return parent.querySelector(
        "span[aria-label='AMP logo']",
      ) as HTMLSpanElement | null
    }
  }

  console.debug("Failed to find corresponding AMP logo <span> for", anchor)

  return null
}

/// Remove all the AMP popovers, which are displayed at the bottom of the screen on Google Images results.
///
/// This seems to be officially called the "Google AMP Viewer"
function removeAMPPopovers() {
  const moreInfoAnchors = document.querySelectorAll(
    "a[href='https://support.google.com/websearch/?p=AMP",
  )

  moreInfoAnchors.forEach((moreInfoAnchor) => {
    const ampAnchor = moreInfoAnchor.previousElementSibling

    if (ampAnchor === null || ampAnchor.nodeName !== "A") {
      console.debug(
        "Found an AMP support link not next to an anchor",
        moreInfoAnchor,
        ampAnchor,
      )
      return
    }

    const cWizElement = ampAnchor.closest("c-wiz")

    if (cWizElement === null) {
      console.debug("Couldn't find parent c-wiz element")
      return
    }

    if (
      cWizElement.children.item(0)?.getAttribute("role") !== "button" ||
      cWizElement.children.item(0)?.ariaLabel?.includes("AMP") !== true
    ) {
      console.debug(
        "c-wiz element doesn't contain AMP header as first child",
        cWizElement,
        cWizElement.children.item(0),
      )
      return
    }

    console.info("Removing AMP Popover", cWizElement.parentElement)
    cWizElement.parentElement?.remove()
  })
}

async function replaceAMPLinks(ignoredHostnames: string[]): Promise<void> {
  const ampContainer = document.querySelector("div[aria-label*='AMP']")

  if (ampContainer) {
    const anchors = ampContainer.querySelectorAll("a")

    for (const anchor of Array.from(anchors)) {
      if (anchor.innerText == anchor.href) {
        // This is the actual URL
        try {
          // This can throw on Safari 16 when the href is an empty string
          const url = new URL(anchor.href)
          openURL(url, ignoredHostnames, true, "AMP", "replace")
          // This previously used the return value from `openURL` (`didOpen`) and `return`ed, but it was within a `forEach` so the return didn't do anything. It's not clear what the intention was so it was removed in 1.2.1.
        } catch {
          console.warn("Found an anchor with an invalid URL", anchor.href)
        }
      }
    }
  }

  // removeAMPPopovers()

  const ampAnchor = document.body.querySelectorAll("a[data-ved]")
  console.debug(`Found ${ampAnchor.length} AMP links`)

  const modifyAnchorPromises = Array.from(ampAnchor).map((element) => {
    const anchor = element as HTMLAnchorElement & { dataset: { ved: string } }
    return modifyAnchorIfRequired(anchor, ignoredHostnames)
  })

  const modifiedURLs = await Promise.all(modifyAnchorPromises)
  const newlyReplacedURLs = modifiedURLs.compactMap((element) => {
    return element
  })

  new NativeAppCommunicator().logReplacedLinks(newlyReplacedURLs)

  console.info(
    `A total of ${
      Object.keys(anchorOnclickListeners).length
    } AMP links have been replaced`,
  )

  document.body.dataset.overampedReplacedLinksCount = `${
    Object.keys(anchorOnclickListeners).length
  }`
}

async function modifyAnchorIfRequired(
  anchor: HTMLAnchorElement & { dataset: { ved: string } },
  ignoredHostnames: string[],
): Promise<URL | undefined> {
  console.debug("Checking anchor", anchor)

  const ved = anchor.dataset.ved
  let hasCanonicalURL = false

  interface AnchorAttributes {
    url: string
  }

  // The URL to redirect to, if found.
  const attributes = ((): AnchorAttributes | null => {
    const ampCur = anchor.dataset.ampCur

    if (ampCur && ampCur.length > 0) {
      // data-amp-cur is available on News search results (not news.google)
      // and has the full canonical URL
      hasCanonicalURL = true
      return { url: ampCur }
    }

    if (anchor.dataset.amp) {
      return { url: anchor.dataset.amp }
    }

    if (anchor.dataset.cur) {
      return { url: anchor.dataset.cur }
    } else {
      return null
    }
  })()

  if (!attributes) {
    console.debug(`Failed to get final URL from anchor`, anchor)
    return
  }

  const { url: anchorURLString } = attributes

  let anchorURL: URL

  try {
    anchorURL = new URL(anchorURLString)
  } catch {
    console.warn("Anchor has invalid URL", anchorURLString)
    return
  }

  if (anchorURL.hostname === window.location.hostname) {
    // Do not override internal links, e.g. links to `"#"` used for anchors acting as buttons
    // `role="button"` could also be used but may exclude too many anchors
    console.debug("Anchor URL is internal; not modifying")
    return
  }

  console.debug(`URL from attribute: ${anchorURL.toString()}`)

  const ampIcon = findAMPLogoRelativeToAnchor(anchor)
  let modifiedAnchor = anchorOnclickListeners[ved]

  let logRedirection: boolean

  if (!hasCanonicalURL) {
    const { canAccess: canAccessURL } = await browser.runtime.sendMessage({
      request: "canAccessURL",
      payload: {
        url: anchorURL.toString(),
      },
    })

    logRedirection = !canAccessURL

    if (!canAccessURL) {
      // Only de-AMP the URL if redirecting to the AMP URL
      // wouldn't be redirected.
      anchorURL = deAMPURL(anchorURL)
      console.debug(`De-AMPed URL: ${anchorURL}`)
    }
  } else {
    logRedirection = true
  }

  if (ignoredHostnames.includes(anchorURL.hostname)) {
    console.debug(
      `Not modifying anchor; ${anchorURL.hostname} is in ignore list`,
      anchorOnclickListeners,
    )

    if (modifiedAnchor) {
      unmodifyAnchor(anchor, modifiedAnchor, ampIcon)
    }

    return
  }

  if (modifiedAnchor) {
    console.debug("Not modifying anchor; it has already been modified")
    return
  }

  console.debug("Modifying anchor to intercept opening")

  const originalHREF = anchor.href

  anchor.href = anchorURL.toString()

  function interceptAMPLink(event: MouseEvent) {
    if (openURL(anchorURL, ignoredHostnames, logRedirection, "AMP", "push")) {
      event.preventDefault()
      event.stopImmediatePropagation()
      return false
    } else {
      return true
    }
  }

  anchor.addEventListener("click", interceptAMPLink)

  modifiedAnchor = {
    listener: interceptAMPLink,
    originalHREF,
  }

  if (ampIcon !== null) {
    modifiedAnchor.ampIconDisplay = ampIcon.style.display
    ampIcon.style.display = "none"
  }

  anchorOnclickListeners[ved] = modifiedAnchor

  return new URL(anchor.href)
}

function unmodifyAnchor(
  anchor: HTMLAnchorElement & { dataset: { ved: string } },
  modifiedAnchor: OverriddenAnchor,
  ampIcon: HTMLSpanElement | null,
) {
  console.debug("Anchor has been modified; reverting to", modifiedAnchor)
  anchor.href = modifiedAnchor.originalHREF
  anchor.removeEventListener("click", modifiedAnchor.listener)

  if (ampIcon && modifiedAnchor.ampIconDisplay !== undefined) {
    ampIcon.style.display = modifiedAnchor.ampIconDisplay
  }

  delete anchorOnclickListeners[anchor.dataset.ved]
}
