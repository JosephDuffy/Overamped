interface OverriddenAnchor {
  listener: (event: MouseEvent) => boolean
  originalHREF: string
  ampIconDisplay?: string
}
const anchorOnclickListeners: {
  [ved: string]: OverriddenAnchor
} = {}

function replaceAMPLinks(ignoredHostnames: string[]) {
  const ampAnchor = document.body.querySelectorAll("a[data-amp-cur]")
  console.debug(`Found ${ampAnchor.length} AMP links`)

  ampAnchor.forEach((element) => {
    const anchor = element as HTMLAnchorElement

    console.debug("Checking AMP anchor", anchor)

    const ved = anchor.dataset.ved

    if (!ved) {
      console.debug(anchor, "Does not have data-ved attribute")
      return
    }

    const ampIcon = anchor.querySelector(
      "span[aria-label='AMP logo']",
    ) as HTMLSpanElement | null

    const finalURL = new URL(
      (() => {
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
        const ampCur = anchor.dataset.ampCur!

        if (ampCur.length > 0) {
          return ampCur
        }

        return anchor.dataset.cur ?? anchor.href
      })(),
    )

    console.debug(`URL from attribute: ${finalURL.toString()}`)

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

    const finalSearchParams = new URLSearchParams()

    finalURL.searchParams.forEach((value, key) => {
      if (value != "amp" && key != "amp") {
        finalSearchParams.append(key, value)
      } else {
        console.debug(`Removing ${key}=${value} from final URL`)
      }
    })

    finalURL.search = finalSearchParams.toString()

    if (finalURL.pathname.startsWith("/amp/")) {
      console.debug("Removing amp/ prefix")
      finalURL.pathname = finalURL.pathname.substring(4)
    } else if (finalURL.pathname.endsWith("/amp/")) {
      console.debug("Removing amp/ postfix")
      finalURL.pathname = finalURL.pathname.substring(
        finalURL.pathname.length - "amp/".length,
      )
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
}

let replaceAMPLinksWithStoredIgnoredList: () => void = () => {
  replaceAMPLinks([])
}

let readyStateChangeListener: (() => void) | undefined

function applyIgnoredList(ignoredHostnames: string[]) {
  if (document.readyState == "loading") {
    console.debug(
      "Ignore list has been loaded but the webpage is still loading",
    )

    if (readyStateChangeListener) {
      document.removeEventListener("readystatechange", readyStateChangeListener)
    }
    readyStateChangeListener = () => {
      applyIgnoredList(ignoredHostnames)
    }
    document.addEventListener("readystatechange", readyStateChangeListener)
    return
  }
  document.removeEventListener(
    "DOMNodeInserted",
    replaceAMPLinksWithStoredIgnoredList,
  )

  replaceAMPLinksWithStoredIgnoredList = () => {
    replaceAMPLinks(ignoredHostnames)
  }

  replaceAMPLinksWithStoredIgnoredList()

  // Support "More Results"
  document.addEventListener(
    "DOMNodeInserted",
    replaceAMPLinksWithStoredIgnoredList,
  )
}

browser.storage.local
  .get("ignoredHostnames")
  .then((storage) => {
    const ignoredHostnames =
      (storage["ignoredHostnames"] as string[] | undefined) ?? []

    console.debug("Loaded ignored hostnames list", ignoredHostnames)

    applyIgnoredList(ignoredHostnames)
  })
  .catch((error) => {
    console.error("Failed to load ignoredHostnames setting", error)
  })

browser.storage.onChanged.addListener((changes) => {
  if (changes["ignoredHostnames"] && changes["ignoredHostnames"].newValue) {
    console.debug(
      "Ignored hostnames setting changed",
      changes["ignoredHostnames"],
    )
    const ignoredHostnames = changes["ignoredHostnames"].newValue

    applyIgnoredList(ignoredHostnames)
  }
})
