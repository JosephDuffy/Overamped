<script lang="ts">
  import Popup from "./Popup.svelte"
  import NativeAppCommunicator from "../../NativeAppCommunicator"
  import { dataIsGoogleTabData, GoogleTabData, TabData } from "./TabData"
  import FeedbackButton from "./FeedbackButton.svelte"
  import GooglePopup from "./GooglePopup.svelte"
  import SettingsButton from "./SettingsButton.svelte"

  const tabData = loadTabData()

  async function loadTabData(): Promise<TabData> {
    const ignoredHostnamesPromise =
      new NativeAppCommunicator().ignoredHostnames()
    const currentTabPromise = browser.tabs.getCurrent()
    const [ignoredHostnames, currentTab] = await Promise.all([
      ignoredHostnamesPromise,
      currentTabPromise,
    ])

    const tabContainsAMPPage = await checkTabContainsAMPPage(currentTab)

    const canonicalURL = await (async () => {
      if (tabContainsAMPPage) {
        return await canonicalURLForTab(currentTab)
      } else {
        return undefined
      }
    })()

    const replacedLinksCount = await overampedReplacedLinksCountInTab(
      currentTab,
    )

    if (replacedLinksCount) {
      return {
        ignoredHostnames,
        currentTab,
        replacedLinksCount,
        canonicalURL,
      } as GoogleTabData
    } else {
      return {
        ignoredHostnames,
        currentTab,
        canonicalURL,
      }
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

  async function checkTabContainsAMPPage(
    tab: browser.tabs.Tab,
  ): Promise<boolean> {
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

  function tabHasURL(
    tab: browser.tabs.Tab,
  ): tab is browser.tabs.Tab & { url: string } {
    return typeof tab.url !== "undefined"
  }
</script>

<main>
  {#await tabData}
    <p>Loading tab data...</p>
  {:then tabData}
    {#if tabHasURL(tabData.currentTab)}
      <!-- The spread is required to satisfy the type system. Maybe TypeScript 4.4 will fix the need for this -->
      <Popup tabData={{ ...tabData, currentTab: tabData.currentTab }} />
    {:else if dataIsGoogleTabData(tabData)}
      <GooglePopup {tabData} />
    {:else}
      <p>Overamped is not available for the current page</p>
    {/if}
    <div>
      <SettingsButton />
      <FeedbackButton currentTab={tabData.currentTab} />
    </div>
  {:catch error}
    <p style="color: red">{error.message}</p>
  {/await}
</main>
