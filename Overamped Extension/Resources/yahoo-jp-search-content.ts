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
  [ylk: string]: OverriddenAnchor
} = {}

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

function replaceAMPLinks(ignoredHostnames: string[]) {
  const ampAnchor = document.body.querySelectorAll("a[data-amp-cur]")
  console.debug(`Found ${ampAnchor.length} AMP links`)

  const modifyAnchorPromises = Array.from(ampAnchor).map((element) => {
    const anchor = element as HTMLAnchorElement & {
      dataset: { ampCur: string }
    }
    return modifyAnchorIfRequired(anchor, ignoredHostnames)
  })

  Promise.all(modifyAnchorPromises).then((modifiedURLs) => {
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
  })
}

async function modifyAnchorIfRequired(
  anchor: HTMLAnchorElement & { dataset: { ampCur: string } },
  ignoredHostnames: string[],
): Promise<URL | undefined> {
  console.debug("Checking anchor", anchor)

  if (!anchor.dataset.ylk) {
    console.debug("Missing ylk data on anchor", anchor)
    return
  }

  const ylk = anchor.dataset.ylk

  const anchorURLString = anchor.dataset.ampCur

  if (!anchorURLString) {
    console.debug(`Failed to get final URL from anchor`, anchor)
    return
  }

  let anchorURL = new URL(anchorURLString)

  console.debug(`URL from attribute: ${anchorURL.toString()}`)

  const ampIcon = findAMPLogoRelativeToAnchor(anchor)
  let modifiedAnchor = anchorOnclickListeners[ylk]

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

  anchorOnclickListeners[ylk] = modifiedAnchor

  return new URL(anchor.href)
}

function unmodifyAnchor(
  anchor: HTMLAnchorElement & { dataset: { ampCur: string } },
  modifiedAnchor: OverriddenAnchor,
  ampIcon: HTMLDivElement | null,
) {
  console.debug("Anchor has been modified; reverting to", modifiedAnchor)
  anchor.href = modifiedAnchor.originalHREF
  anchor.removeEventListener("click", modifiedAnchor.listener)

  if (ampIcon && modifiedAnchor.ampIconDisplay !== undefined) {
    ampIcon.style.display = modifiedAnchor.ampIconDisplay
  }

  if (anchor.dataset.ylk) {
    delete anchorOnclickListeners[anchor.dataset.ylk]
  }
}
