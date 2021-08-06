<script lang="ts">
  import type { TabData } from "./TabData"
  import NativeAppCommunicator from "../../NativeAppCommunicator"

  export let tabData: TabData
  export const currentTabURL = new URL(tabData.currentTab.url)
  $: isDisabledOnCurrentDomain = tabData.ignoredHostnames.includes(
    currentTabURL.hostname,
  )

  const nativeAppCommunicator = new NativeAppCommunicator()

  export function disableOverampedOnCurrentDomain() {
    nativeAppCommunicator
      .ignoreHostname(currentTabURL.hostname)
      .then((ignoredHostnames) => {
        console.info(`${currentTabURL.hostname} has been added to ignore list`)

        tabData.ignoredHostnames = ignoredHostnames
      })
      .catch((error) => {
        console.error("Failed to save settings", error)
      })
  }

  export function enableOverampedOnCurrentDomain() {
    nativeAppCommunicator
      .removeIgnoredHostname(currentTabURL.hostname)
      .then((ignoredHostnames) => {
        console.info(
          `${currentTabURL.hostname} has been removed from ignore list`,
        )

        tabData.ignoredHostnames = ignoredHostnames
      })
      .catch((error) => {
        console.error("Failed to save settings", error)
      })
  }
</script>

<div>
  {#if isDisabledOnCurrentDomain}
    <button on:click={enableOverampedOnCurrentDomain}>
      Enable Overamped on {currentTabURL.hostname}
    </button>
  {:else}
    <button on:click={disableOverampedOnCurrentDomain}>
      Disable Overamped on {currentTabURL.hostname}
    </button>
  {/if}
  <p id="toggleAllowListButtonExplanation">
    If Overamped is disabled for {currentTabURL.hostname} it will not redirect to
    the canonical version of {currentTabURL.hostname}.
  </p>
  {#if tabData.canonicalURL}
    <p id="openCanonicalLinkExplanation">
      It looks like this page is an AMP page. You may wish to
      <a
        id="canonicalAnchor"
        href={tabData.canonicalURL}
        on:click={(event) => {
          window.open(event.currentTarget.href)
          return false
        }}>open the canonical version of this website</a
      >.
    </p>
  {/if}
</div>
