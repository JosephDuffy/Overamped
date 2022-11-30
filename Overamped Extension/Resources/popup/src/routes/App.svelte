<script lang="ts">
  import Popup from "./Popup.svelte"
  import NativeAppCommunicator from "overamped-shared/NativeAppCommunicator"
  import { dataIsGoogleTabData } from "./TabData"
  import type { GoogleTabData, TabData } from "./TabData"
  import FeedbackButton from "./FeedbackButton.svelte"
  import GooglePopup from "./GooglePopup.svelte"
  import SettingsButton from "./SettingsButton.svelte"

  const tabData = loadTabData()

  async function loadTabData(): Promise<TabData | GoogleTabData> {
    console.debug("Loading tab data")
    const ignoredHostnamesPromise =
      new NativeAppCommunicator().ignoredHostnames()
    const currentTabPromise = browser.tabs.getCurrent()
    const permissionsPromise = browser.permissions.getAll()
    const [ignoredHostnames, currentTab, permissions] = await Promise.all([
      ignoredHostnamesPromise,
      currentTabPromise,
      permissionsPromise,
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

    if (replacedLinksCount !== undefined) {
      return {
        ignoredHostnames,
        currentTab,
        replacedLinksCount,
        canonicalURL,
        permittedOrigins: permissions.origins,
      }
    } else {
      return {
        ignoredHostnames,
        currentTab,
        canonicalURL,
        permittedOrigins: permissions.origins,
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

  function tabDataHasURL(
    tabData: TabData | GoogleTabData,
  ): tabData is
    | (TabData & { currentTab: { url: string } })
    | (GoogleTabData & { currentTab: { url: string } }) {
    return typeof tabData.currentTab.url !== "undefined"
  }
</script>

<main>
  {#await tabData}
    <p>Loading tab data...</p>
    <style>
      p {
        text-align: center;
      }
    </style>
  {:then tabData}
    {#if tabDataHasURL(tabData)}
      {#if dataIsGoogleTabData(tabData)}
        <GooglePopup {tabData} />
      {:else}
        <Popup {tabData} />
      {/if}
    {:else}
      <p>Overamped is not available for the current page</p>
    {/if}
    <div class="buttonsContainer">
      <SettingsButton />
      <FeedbackButton {tabData} />
    </div>
    <style>
      .buttonsContainer {
        display: grid;
        grid-template-columns: calc(50% - 4px) calc(50% - 4px);
        grid-template-rows: auto;
        gap: 8px;
      }
    </style>
  {:catch error}
    <p style="color: red">{error.message}</p>
  {/await}
</main>
