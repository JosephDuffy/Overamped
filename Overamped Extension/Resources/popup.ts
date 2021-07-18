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
const currentPageDomainSpans = document.getElementsByClassName(
  "currentPageDomain",
)! as HTMLCollectionOf<HTMLLinkElement>

// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
const replacedLinksCountSpans = document.getElementsByClassName(
  "replacedLinksCount",
)! as HTMLCollectionOf<HTMLLinkElement>

// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
const toggleAllowListButtonExplanation = document.getElementById(
  "toggleAllowListButtonExplanation",
)!

// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
const submitFeedbackButton = document.getElementById(
  "submitFeedback",
)! as HTMLButtonElement

const nativeAppCommunicator = new NativeAppCommunicator()

const settingsPromise = nativeAppCommunicator.ignoredHostnames()
const currentTabPromise = browser.tabs.getCurrent()

Promise.all([settingsPromise, currentTabPromise])
  .then(([ignoredHostnames, currentTab]) => {
    console.debug("Loaded ignored hostnames", ignoredHostnames)

    configurePage(ignoredHostnames, currentTab)
  })
  .catch((error) => {
    console.error(error)
    alert(error)
  })

function configurePage(
  ignoredHostnames: string[],
  currentTab: browser.tabs.Tab,
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
    browser.tabs
      .executeScript(currentTab.id, {
        code: `document.body.dataset.overampedReplacedLinksCount`,
      })
      .then((result) => {
        console.log("result", result)
        if ((result.length === 1, typeof result[0] === "string")) {
          const replacedLinksCount = parseInt(result[0])

          showGoogleUI(replacedLinksCount)
        } else {
          showNonGoogleUI(ignoredHostnames, currentTabURL)
        }
      })
      .catch((error) => {
        console.error("Failed to execute script", error)
      })
  } else {
    showNonGoogleUI(ignoredHostnames, currentTabURL)
  }
}

function openSubmitFeedbackPage(currentTabURL?: string) {
  const feedbackURL = new URL("overamped:feedback")

  if (currentTabURL) {
    feedbackURL.searchParams.append("url", currentTabURL)
  }

  browser.tabs.create({ url: feedbackURL.toString() })
}

function showGoogleUI(replacedLinksCount: number) {
  googleContentContainer.hidden = false
  nonGoogleContentContainer.hidden = true

  Array.from(replacedLinksCountSpans).forEach((span) => {
    span.innerText = `${replacedLinksCount}`
  })
}

function showNonGoogleUI(ignoredHostnames: string[], currentTabURL: string) {
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
}

// Open all links in a new tab
Array.from(document.querySelectorAll("a")).forEach((anchor) => {
  anchor.onclick = () => {
    browser.tabs.create({ url: anchor.href })
    return false
  }
})
