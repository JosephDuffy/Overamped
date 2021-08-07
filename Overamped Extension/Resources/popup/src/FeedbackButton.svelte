<script lang="ts">
  export let currentTab: browser.tabs.Tab

  function openFeedback() {
    const feedbackURL = new URL("overamped://feedback")

    if (currentTab.url) {
      feedbackURL.searchParams.append("url", currentTab.url)
    }

    window.open(feedbackURL.toString())
  }
</script>

<button on:click={openFeedback}>Submit Feedback</button>
