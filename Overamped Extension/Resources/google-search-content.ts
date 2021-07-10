import deampURL from "./deampURL"
import ExtensionApplier from "./ExtensionApplier"

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

function replaceAMPLinks(ignoredHostnames: string[]) {
  const ampAnchor = document.body.querySelectorAll("a[data-ved]")
  console.debug(`Found ${ampAnchor.length} AMP links`)

  ampAnchor.forEach((element) => {
    const anchor = element as HTMLAnchorElement

    console.debug("Checking AMP anchor", anchor)

    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const ved = anchor.dataset.ved!

    const anchorURLString = (() => {
      const ampCur = anchor.dataset.ampCur

      if (ampCur && ampCur.length > 0) {
        return ampCur
      }

      return anchor.dataset.cur ?? (anchor.href as string | undefined)
    })()

    if (!anchorURLString) {
      console.debug(`Failed to get final URL from anchor`, anchor)
      return
    }

    const anchorURL = new URL(anchorURLString)

    console.debug(`URL from attribute: ${anchorURL.toString()}`)

    const finalURL = deampURL(anchorURL)

    const ampIcon = findAMPLogoRelativeToAnchor(anchor)
    let modifiedAnchor = anchorOnclickListeners[ved]

    if (ignoredHostnames.includes(finalURL.hostname)) {
      console.debug(
        `Not modifying anchor; ${finalURL.hostname} is in ignore list`,
        anchorOnclickListeners,
      )

      if (modifiedAnchor) {
        console.debug("Anchor has been modified; reverting to", modifiedAnchor)
        anchor.href = modifiedAnchor.originalHREF
        anchor.removeEventListener("click", modifiedAnchor.listener)

        if (ampIcon && modifiedAnchor.ampIconDisplay !== undefined) {
          ampIcon.style.display = modifiedAnchor.ampIconDisplay
        }

        delete anchorOnclickListeners[ved]
      }

      return
    } else if (modifiedAnchor) {
      // Link has already been overridden.
      return
    }

    const finalURLString = finalURL.toString()

    console.info(`De-AMPed URL: ${finalURLString}`)

    const originalHREF = anchor.href

    anchor.href = finalURLString

    function interceptAMPLink(event: MouseEvent) {
      event.stopImmediatePropagation()

      console.debug("Pushing non-AMP URL")
      window.location.assign(finalURLString)

      return false
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
  })

  document.body.dataset.overampedReplacedLinksCount = `${
    Object.keys(anchorOnclickListeners).length
  }`
}

new ExtensionApplier(document, replaceAMPLinks)
