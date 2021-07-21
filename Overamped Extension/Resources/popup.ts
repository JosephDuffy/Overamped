import NativeAppCommunicator from "./NativeAppCommunicator"

// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
const toggleAllowListButton = document.getElementById(
  "toggleAllowListButton",
)! as HTMLButtonElement

// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
const googleContentContainer = document.getElementById(
  "googleContent",
)! as HTMLDivElement

// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
const nonGoogleContentContainer = document.getElementById(
  "nonGoogleContent",
)! as HTMLDivElement

// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
const openCanonicalLinkExplanation = document.getElementById(
  "openCanonicalLinkExplanation",
)! as HTMLDivElement

// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
const currentPageDomainSpans = document.getElementsByClassName(
  "currentPageDomain",
)! as HTMLCollectionOf<HTMLLinkElement>

// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
const replacedLinksCountSpans = document.getElementsByClassName(
  "replacedLinksCount",
)! as HTMLCollectionOf<HTMLLinkElement>

// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
const canonicalAnchor = document.getElementById(
  "canonicalAnchor",
)! as HTMLAnchorElement

// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
const toggleAllowListButtonExplanation = document.getElementById(
  "toggleAllowListButtonExplanation",
)!

// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
const submitFeedbackButton = document.getElementById(
  "submitFeedback",
)! as HTMLButtonElement

;(async () => {
  try {
    await applyToPage()
  } catch (error) {
    console.error("Failed to update page", error)
  }
})()

async function applyToPage() {
  const nativeAppCommunicator = new NativeAppCommunicator()
  const settingsPromise = nativeAppCommunicator.ignoredHostnames()
  const currentTabPromise = browser.tabs.getCurrent()
  const [ignoredHostnames, currentTab] = await Promise.all([
    settingsPromise,
    currentTabPromise,
  ])
  configurePage(ignoredHostnames, currentTab, nativeAppCommunicator)
}

async function configurePage(
  ignoredHostnames: string[],
  currentTab: browser.tabs.Tab,
  nativeAppCommunicator: NativeAppCommunicator,
) {
  const currentTabURL = currentTab.url
  if (!currentTabURL) {
    toggleAllowListButtonExplanation.innerText =
      "Overamped is not available for the current page."
    toggleAllowListButton.hidden = true
    googleContentContainer.hidden = true
    return
  }

  submitFeedbackButton.onclick = () => {
    openSubmitFeedbackPage(currentTabURL)
    return false
  }

  if (currentTab.id) {
    const replacedLinksCount = await overampedReplacedLinksCountInTab(
      currentTab,
    )
    if (replacedLinksCount !== undefined) {
      showGoogleUI(replacedLinksCount)
    } else {
      await showNonGoogleUI(
        ignoredHostnames,
        currentTabURL,
        <browser.tabs.Tab & { url: string }>currentTab,
        nativeAppCommunicator,
      )
    }
  } else {
    await showNonGoogleUI(
      ignoredHostnames,
      currentTabURL,
      <browser.tabs.Tab & { url: string }>currentTab,
      nativeAppCommunicator,
    )
  }
}

function openSubmitFeedbackPage(currentTabURL?: string) {
  const feedbackURL = new URL("overamped:feedback")

  if (currentTabURL) {
    feedbackURL.searchParams.append("url", currentTabURL)
  }

  window.open(feedbackURL.toString())
}

function showGoogleUI(replacedLinksCount: number) {
  googleContentContainer.hidden = false
  nonGoogleContentContainer.hidden = true

  Array.from(replacedLinksCountSpans).forEach((span) => {
    span.innerText = `${replacedLinksCount}`
  })
}

async function showNonGoogleUI(
  ignoredHostnames: string[],
  currentTabURL: string,
  currentTab: browser.tabs.Tab & { url: string },
  nativeAppCommunicator: NativeAppCommunicator,
) {
  toggleAllowListButton.hidden = false
  googleContentContainer.hidden = true
  nonGoogleContentContainer.hidden = false

  const currentURL = new URL(currentTabURL)
  Array.from(currentPageDomainSpans).forEach((span) => {
    span.innerText = currentURL.hostname
  })

  if (ignoredHostnames.includes(currentURL.hostname)) {
    toggleAllowListButton.innerText = `Enable Overamped on ${currentURL.hostname}`

    toggleAllowListButton.onclick = () => {
      toggleAllowListButton.disabled = true
      nativeAppCommunicator
        .removeIgnoredHostname(currentURL.hostname)
        .then(() => {
          console.info(
            `${currentURL.hostname} has been removed from ignore list`,
          )
        })
        .catch((error) => {
          console.error("Failed to save settings", error)
        })
        .finally(() => {
          toggleAllowListButton.disabled = false
        })
      return false
    }
  } else {
    toggleAllowListButton.innerText = `Disable Overamped on ${currentURL.hostname}`

    toggleAllowListButton.onclick = () => {
      toggleAllowListButton.disabled = true

      nativeAppCommunicator
        .ignoreHostname(currentURL.hostname)
        .then(() => {
          console.info(`${currentURL.hostname} has been added to ignore list`)
        })
        .catch((error) => {
          console.error("Failed to save settings", error)
        })
        .finally(() => {
          toggleAllowListButton.disabled = false
        })
      return false
    }
  }

  const isAMPPage = await tabContainsAMPPage(currentTab)

  if (!isAMPPage) {
    openCanonicalLinkExplanation.style.display = "none"
    return
  }

  const canonicalURL = await canonicalURLForTab(currentTab)

  if (canonicalURL === undefined || currentTab.url === canonicalURL) {
    openCanonicalLinkExplanation.style.display = "none"
    return
  }

  canonicalAnchor.href = canonicalURL
  openCanonicalLinkExplanation.style.removeProperty("display")
}

async function tabContainsAMPPage(tab: browser.tabs.Tab): Promise<boolean> {
  const scriptResult = await browser.tabs.executeScript(tab.id, {
    code: `document.documentElement.attributes.hasOwnProperty("amp") || document.documentElement.attributes.hasOwnProperty("⚡")`,
  })
  return (
    scriptResult.length === 1 &&
    typeof scriptResult[0] === "boolean" &&
    scriptResult[0]
  )
}

async function canonicalURLForTab(
  tab: browser.tabs.Tab,
): Promise<string | undefined> {
  const scriptResult = await browser.tabs.executeScript(tab.id, {
    code: `document.head.querySelector("link[rel~='canonical'][href]").href`,
  })
  if (scriptResult.length === 1 && typeof scriptResult[0] === "string") {
    return scriptResult[0]
  } else {
    return undefined
  }
}

async function overampedReplacedLinksCountInTab(
  tab: browser.tabs.Tab,
): Promise<number | undefined> {
  const scriptResult = await browser.tabs.executeScript(tab.id, {
    code: `document.body.dataset.overampedReplacedLinksCount`,
  })
  if (scriptResult.length === 1 && typeof scriptResult[0] === "string") {
    const replacedLinksCount = parseInt(scriptResult[0])

    return replacedLinksCount
  } else {
    return undefined
  }
}

// Open all links in a new tab
Array.from(document.querySelectorAll("a")).forEach((anchor) => {
  anchor.onclick = () => {
    window.open(anchor.href)
    return false
  }
})
