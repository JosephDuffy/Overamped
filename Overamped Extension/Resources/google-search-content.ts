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

async function replaceAMPLinks(ignoredHostnames: string[]): Promise<void> {
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

  const anchorURLString = (() => {
    const ampCur = anchor.dataset.ampCur

    if (ampCur && ampCur.length > 0) {
      // data-amp-cur is available on News search results (not news.google)
      // and has the full canonical URL
      hasCanonicalURL = true
      return ampCur
    }

    if (anchor.dataset.amp) {
      return anchor.dataset.amp
    }

    return anchor.dataset.cur
  })()

  if (!anchorURLString) {
    console.debug(`Failed to get final URL from anchor`, anchor)
    return
  }

  let anchorURL = new URL(anchorURLString)

  if (anchorURL.hostname === window.location.hostname) {
    // Do not override internal links, e.g. links to `"#"` used for anchors acting as buttons
    // `role="button"` could also be used but may exclude too many anchors
    return
  }

  console.debug(`URL from attribute: ${anchorURL.toString()}`)

  const ampIcon = findAMPLogoRelativeToAnchor(anchor)
  let modifiedAnchor = anchorOnclickListeners[ved]

  if (!hasCanonicalURL) {
    const { canAccess: canAccessURL } = await browser.runtime.sendMessage({
      request: "canAccessURL",
      payload: {
        url: anchorURL.toString(),
      },
    })

    if (!canAccessURL) {
      // Only de-AMP the URL if redirecting to the AMP URL
      // wouldn't be redirected.
      anchorURL = deAMPURL(anchorURL)
      console.debug(`De-AMPed URL: ${anchorURL}`)
    }
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
  } else if (modifiedAnchor) {
    console.debug("Not modifying anchor; it has already been modified")
    return
  }

  console.debug("Modifying anchor to intercept opening")

  const originalHREF = anchor.href

  anchor.href = anchorURL.toString()

  function interceptAMPLink(event: MouseEvent) {
    if (openURL(anchorURL, ignoredHostnames, "push")) {
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

  if (ampIcon) {
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
