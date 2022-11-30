<script lang="ts">
  import type { TabData } from "./TabData"

  export let tabData: TabData

  function openFeedback() {
    const feedbackURL = new URL("overamped://feedback")

    if (tabData.currentTab.url) {
      feedbackURL.searchParams.append("url", tabData.currentTab.url)
    }

    if (tabData.permittedOrigins) {
      feedbackURL.searchParams.append(
        "permittedOrigins",
        tabData.permittedOrigins.join(","),
      )
    }

    window.open(feedbackURL.toString())
  }
</script>

<button on:click={openFeedback}>Submit Feedback</button>
