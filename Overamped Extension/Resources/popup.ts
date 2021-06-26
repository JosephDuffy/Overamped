// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
const toggleAllowListButton = document.getElementById(
  "toggleAllowListButton",
)! as HTMLButtonElement
// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
const currentPageDomainSpan = document.getElementById("currentPageDomain")!

const settingsPromise = browser.storage.local.get("ignoredHostnames")
const currentTabPromise = browser.tabs.getCurrent()

Promise.all([settingsPromise, currentTabPromise]).then(
  ([settings, currentTab]) => {
    console.debug("Loaded initial settings", settings)

    configurePage(
      Array.isArray(settings["ignoredHostnames"])
        ? (settings["ignoredHostnames"] as string[])
        : [],
      currentTab,
    )

    browser.storage.onChanged.addListener((changes) => {
      if (changes["ignoredHostnames"] && changes["ignoredHostnames"].newValue) {
        console.debug(
          "Ignored hostnames setting changed",
          changes["ignoredHostnames"],
        )
        configurePage(
          Array.isArray(changes["ignoredHostnames"].newValue)
            ? changes["ignoredHostnames"].newValue
            : [],
          currentTab,
        )
      }
    })
  },
)

function configurePage(
  ignoredHostnames: string[],
  currentTab: browser.tabs.Tab,
) {
  if (!currentTab.url) {
    currentPageDomainSpan.innerText = "Failed to load URL"
    return
  }

  const currentURL = new URL(currentTab.url)
  currentPageDomainSpan.innerText = currentURL.hostname

  if (ignoredHostnames.includes(currentURL.hostname)) {
    toggleAllowListButton.innerText = `Disable AMP on ${currentURL.hostname}`

    toggleAllowListButton.onclick = () => {
      toggleAllowListButton.disabled = true
      const newIgnoredHostnames = ignoredHostnames.filter((ignoredHostname) => {
        ignoredHostname !== currentURL.hostname
      })
      browser.storage.local
        .set({
          ignoredHostnames: newIgnoredHostnames,
        })
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
    toggleAllowListButton.innerText = `Enable AMP on ${currentURL.hostname}`

    toggleAllowListButton.onclick = () => {
      toggleAllowListButton.disabled = true

      const newIgnoredHostnames = [...ignoredHostnames, currentURL.hostname]
      browser.storage.local
        .set({
          ignoredHostnames: newIgnoredHostnames,
        })
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
