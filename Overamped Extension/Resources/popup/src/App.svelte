<script lang="ts">
  import Popup from "./Popup.svelte"
  import NativeAppCommunicator from "../../NativeAppCommunicator"
  import { dataIsGoogleTabData, GoogleTabData, TabData } from "./TabData"
  import Footer from "./Footer.svelte"
  import GooglePopup from "./GooglePopup.svelte"

  const tabData = loadTabData()

  async function loadTabData(): Promise<TabData> {
    const ignoredHostnamesPromise =
      new NativeAppCommunicator().ignoredHostnames()
    const currentTabPromise = browser.tabs.getCurrent()
    const [ignoredHostnames, currentTab] = await Promise.all([
      ignoredHostnamesPromise,
      currentTabPromise,
    ])

    const replacedLinksCount = await overampedReplacedLinksCountInTab(
      currentTab,
    )
    if (replacedLinksCount) {
      return {
        ignoredHostnames,
        currentTab,
        replacedLinksCount,
      } as GoogleTabData
    } else {
      return {
        ignoredHostnames,
        currentTab,
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
</script>

<main>
  {#await tabData}
    <p>Loading tab data...</p>
  {:then tabData}
    {#if dataIsGoogleTabData(tabData)}
      <GooglePopup {tabData} />
    {:else}
      <Popup {tabData} />
    {/if}
    <Footer />
  {:catch error}
    <p style="color: red">{error.message}</p>
  {/await}
</main>
